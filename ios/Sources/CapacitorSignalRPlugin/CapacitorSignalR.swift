import Foundation
import SignalRClient
import SwiftyJSON

@objc public class CapacitorSignalR: NSObject {
    private var hubConnection: HubConnection?
    private var connectionId: String?
    private var connectionState: HubConnectionState = .disconnected
    private weak var plugin: CapacitorSignalRPlugin?
    private var eventSubscriptions: [String: SubscriptionToken] = [:]
    
    public func setPlugin(_ plugin: CapacitorSignalRPlugin) {
        self.plugin = plugin
    }
    
    @objc public func create(options: [String: Any]) throws -> [String: Any] {
        guard let urlString = options["url"] as? String,
              let url = URL(string: urlString) else {
            throw NSError(domain: "CapacitorSignalR", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Valid URL is required"])
        }
        
        var builder = HubConnectionBuilder(url: url)
            .withLogging(minLogLevel: .error)
        
        // Configure HTTP connection options
        builder = builder.withHttpConnectionOptions { httpOptions in
            // Access token
            if let accessToken = options["accessToken"] as? String, !accessToken.isEmpty {
                httpOptions.accessTokenProvider = {
                    return accessToken
                }
            }
            
            // Skip negotiate
            if let shouldSkipNegotiate = options["shouldSkipNegotiate"] as? Bool {
                httpOptions.skipNegotiation = shouldSkipNegotiate
            }
            
            // Headers
            if let headers = options["headers"] as? [[String: String]] {
                var headerDict: [String: String] = [:]
                for header in headers {
                    if let name = header["name"], let value = header["value"] {
                        headerDict[name] = value
                    }
                }
                if !headerDict.isEmpty {
                    httpOptions.headers = headerDict
                }
            }
            
            // Request timeout (handshake response timeout)
            if let timeout = options["handshakeResponseTimeout"] as? Double, timeout > 0 {
                httpOptions.requestTimeout = TimeInterval(timeout / 1000) // Convert ms to seconds
            }
        }
        
        // Configure hub connection options
        builder = builder.withHubConnectionOptions { hubOptions in
            // Keep alive interval
            if let keepAlive = options["keepAliveInterval"] as? Double, keepAlive > 0 {
                hubOptions.keepAliveInterval = keepAlive / 1000 // Convert ms to seconds
            }
            
            // Server timeout
            if let serverTimeout = options["serverTimeout"] as? Double, serverTimeout > 0 {
                hubOptions.serverTimeout = serverTimeout / 1000 // Convert ms to seconds
            }
        }
        
        // Configure transport type
        if let transport = options["transport"] as? String {
            switch transport {
            case "WEBSOCKETS":
                builder = builder.withPermittedTransportTypes(.webSockets)
            case "LONG_POLLING":
                builder = builder.withPermittedTransportTypes(.longPolling)
            case "ALL":
                builder = builder.withPermittedTransportTypes(.all)
            default:
                builder = builder.withPermittedTransportTypes(.webSockets)
            }
        }
        
        hubConnection = builder.build()
        
        setupConnectionCallbacks()
        
        return [:]
    }
    
    private func setupConnectionCallbacks() {
        guard let connection = hubConnection else { return }
        
        connection.connectionDidOpen { [weak self] connectionId in
            self?.connectionId = connectionId
            self?.connectionState = .connected
            
            if let plugin = self?.plugin {
                let stateData: [String: Any] = ["state": self?.getConnectionStateString() ?? "connected"]
                plugin.notifyListeners("onConnectionStateChanged", data: stateData)
            }
            
            print("SignalR connection opened with ID: \(connectionId ?? "unknown")")
        }
        
        connection.connectionDidFailToOpen { [weak self] error in
            self?.connectionState = .disconnected
            self?.connectionId = nil
            
            if let plugin = self?.plugin {
                let stateData: [String: Any] = ["state": self?.getConnectionStateString() ?? "disconnected"]
                plugin.notifyListeners("onConnectionStateChanged", data: stateData)
                
                var errorData: [String: Any] = [:]
                if let error = error {
                    errorData["message"] = error.localizedDescription
                }
                plugin.notifyListeners("onClosed", data: errorData)
            }
            
            print("SignalR connection failed to open: \(error?.localizedDescription ?? "Unknown error")")
        }
        
        connection.connectionDidClose { [weak self] error in
            self?.connectionState = .disconnected
            self?.connectionId = nil
            
            if let plugin = self?.plugin {
                let stateData: [String: Any] = ["state": self?.getConnectionStateString() ?? "disconnected"]
                plugin.notifyListeners("onConnectionStateChanged", data: stateData)
                
                var errorData: [String: Any] = [:]
                if let error = error {
                    errorData["message"] = error.localizedDescription
                }
                plugin.notifyListeners("onClosed", data: errorData)
            }
            
            print("SignalR connection closed: \(error?.localizedDescription ?? "No error")")
        }
    }
    
    @objc public func start(completion: @escaping (Bool, String?, [String: Any]?) -> Void) {
        guard let connection = hubConnection else {
            completion(false, "Connection not initialized", nil)
            return
        }
        
        connectionState = .connecting
        
        connection.start { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.connectionState = .disconnected
                    completion(false, error.localizedDescription, nil)
                } else {
                    self?.connectionState = .connected
                    let result: [String: Any] = [
                        "connectionId": self?.connectionId ?? "",
                        "state": self?.getConnectionStateString() ?? "connected"
                    ]
                    completion(true, nil, result)
                }
            }
        }
    }
    
    @objc public func disconnect() {
        guard let connection = hubConnection else { return }
        
        connection.stop { [weak self] error in
            self?.connectionState = .disconnected
            self?.connectionId = nil
            if let error = error {
                print("Error stopping connection: \(error.localizedDescription)")
            } else {
                print("Connection stopped successfully")
            }
        }
    }
    
    @objc public func getConnectionId() -> String? {
        return connectionId
    }
    
    @objc public func getConnectionState() -> String {
        return getConnectionStateString()
    }
    
    @objc public func invoke(methodName: String, args: [Any]?) throws {
        guard let connection = hubConnection, connectionState == .connected else {
            throw NSError(domain: "CapacitorSignalR", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Not connected to SignalR hub"])
        }
        
        let arguments = args ?? []
        connection.send(method: methodName, arguments: arguments) { error in
            if let error = error {
                print("Error invoking method \(methodName): \(error.localizedDescription)")
            } else {
                print("Successfully invoked method: \(methodName)")
            }
        }
    }
    
    @objc public func invokeWithResult(methodName: String, args: [Any]?, completion: @escaping (Bool, Any?, String?) -> Void) {
        guard let connection = hubConnection, connectionState == .connected else {
            completion(false, nil, "Not connected to SignalR hub")
            return
        }
        
        let arguments = args ?? []
        connection.invoke(method: methodName, arguments: arguments) { (result: Any?, error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, nil, error.localizedDescription)
                } else {
                    completion(true, result, nil)
                }
            }
        }
    }
    
    @objc public func on(eventName: String) throws {
        guard let connection = hubConnection else {
            throw NSError(domain: "CapacitorSignalR", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Connection not initialized"])
        }
        
        // Remove existing subscription if any
        off(eventName: eventName)
        
        let subscription = connection.on(method: eventName) { [weak self] (data: Any...) in
            self?.handleReceivedEvent(eventName: eventName, data: data)
        }
        
        eventSubscriptions[eventName] = subscription
        print("Subscribed to event: \(eventName)")
    }
    
    @objc public func off(eventName: String) {
        if let subscription = eventSubscriptions.removeValue(forKey: eventName) {
            hubConnection?.off(subscription)
            print("Unsubscribed from event: \(eventName)")
        }
    }
    
    private func handleReceivedEvent(eventName: String, data: [Any]) {
        guard let plugin = plugin else { return }
        
        var eventData: [String: Any] = ["eventName": eventName]
        
        // Convert data to JSON-serializable format
        if !data.isEmpty {
            if data.count == 1 {
                eventData["data"] = convertToJSONSerializable(data[0])
            } else {
                eventData["data"] = data.map { convertToJSONSerializable($0) }
            }
        }
        
        plugin.notifyListeners("onReceive", data: eventData)
    }
    
    private func convertToJSONSerializable(_ value: Any) -> Any {
        if value is String || value is NSNumber || value is Bool {
            return value
        }
        
        // Try to convert using SwiftyJSON
        do {
            let json = JSON(value)
            if let data = try? json.rawData(),
               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                return jsonObject
            }
        } catch {
            print("Error converting to JSON serializable: \(error)")
        }
        
        // Fallback to string representation
        return String(describing: value)
    }
    
    private func getConnectionStateString() -> String {
        switch connectionState {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .disconnected:
            return "disconnected"
        @unknown default:
            return "disconnected"
        }
    }
}
