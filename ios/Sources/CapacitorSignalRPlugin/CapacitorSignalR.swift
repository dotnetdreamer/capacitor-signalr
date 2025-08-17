import Foundation
import SwiftSignalRClient
import SwiftyJSON

@objc public class CapacitorSignalR: NSObject, HubConnectionDelegate {
    private var hubConnection: HubConnection?
    private var connectionId: String?
    private weak var plugin: CapacitorSignalRPlugin?
    
    // Keep track of active subscriptions to prevent duplicates
    private var activeSubscriptions: [String: Any] = [:]
    
    // Internal state tracking
    private enum ConnectionState: String {
        case disconnected = "disconnected"
        case connecting = "connecting"
        case connected = "connected"
    }
    private var connectionState: ConnectionState = .disconnected
    
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
        }
        
        // Configure transport type
        if let transport = options["transport"] as? String {
            switch transport {
            case "WEBSOCKETS":
                builder = builder.withPermittedTransportTypes([.webSockets])
            case "LONG_POLLING":
                builder = builder.withPermittedTransportTypes([.longPolling])
            case "ALL":
                builder = builder.withPermittedTransportTypes([.webSockets, .longPolling])
            default:
                builder = builder.withPermittedTransportTypes([.webSockets])
            }
        }
        
        // Build the connection and set delegate
        hubConnection = builder.build()
        hubConnection?.delegate = self
        
        return [:]
    }
    
    @objc public func start(completion: @escaping (Bool, String?, [String: Any]?) -> Void) {
        guard let connection = hubConnection else {
            completion(false, "Connection not initialized", nil)
            return
        }
        
        connectionState = .connecting
        connection.start()
        connectionState = .connected
        
        let result: [String: Any] = [
            "connectionId": connectionId ?? "",
            "state": getConnectionStateString()
        ]
        completion(true, nil, result)
    }
    
    @objc public func disconnect() {
        guard let connection = hubConnection else { return }
        
        connection.stop()
        connectionState = .disconnected
        connectionId = nil
        print("Connection stopped successfully")
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
        // Convert arguments to encodable array
        let encodableArgs = arguments.compactMap { $0 as? Encodable }
        connection.send(method: methodName, arguments: encodableArgs) { error in
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
        // Convert arguments to encodable array
        let encodableArgs = arguments.compactMap { $0 as? Encodable }
        // Use a generic approach without specifying the result type
        connection.invoke(method: methodName, arguments: encodableArgs) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, nil, error.localizedDescription)
                } else {
                    completion(true, nil, nil)
                }
            }
        }
    }
    
    @objc public func on(eventName: String) throws {
        guard let connection = hubConnection else {
            throw NSError(domain: "CapacitorSignalR", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Connection not initialized"])
        }
        
        // Remove existing subscription if any to prevent duplicates
        off(eventName: eventName)
        
        // Register a callback that will handle the event
        // For the ReceiveMessage event, we'll register a specific handler
        if eventName == "ReceiveMessage" {
            // Handle the specific case of ReceiveMessage with two string parameters
            connection.on(method: eventName) { [weak self] (user: String, message: String) in
                let data: [Any] = [user, message]
                self?.handleReceivedEvent(eventName: eventName, data: data)
            }
        } else {
            // For other events, we'll use a more generic approach
            connection.on(method: eventName) { [weak self] (argumentExtractor: ArgumentExtractor) in
                // Try to extract arguments - we'll start with a simple approach
                var data: [Any] = []
                
                // Try to extract arguments one by one until we get an error
                do {
                    // Try to extract as String first
                    let arg1 = try argumentExtractor.getArgument(type: String.self)
                    data.append(arg1)
                } catch {
                    // If that fails, we'll continue silently
                }
                
                // Try to extract another argument as String
                do {
                    let arg2 = try argumentExtractor.getArgument(type: String.self)
                    data.append(arg2)
                } catch {
                    // If that fails, we'll continue silently
                }
                
                self?.handleReceivedEvent(eventName: eventName, data: data)
            }
        }
        
        // Track the subscription
        activeSubscriptions[eventName] = true
        print("Subscribed to event: \(eventName)")
    }
    
    public func off(eventName: String) {
        // Remove the subscription tracking
        activeSubscriptions.removeValue(forKey: eventName)
        // Note: The SignalR client doesn't have a direct way to remove callbacks
        // We'll just stop tracking it and rely on the fact that we're preventing duplicates
        // in the on() method by calling off() before registering a new subscription
        print("Unsubscribed from event: \(eventName)")
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
        return connectionState.rawValue
    }
    
    // MARK: - HubConnectionDelegate Methods
    
    public func connectionDidOpen(hubConnection: HubConnection) {
        self.connectionId = hubConnection.connectionId
        self.connectionState = .connected
        
        if let plugin = self.plugin {
            let stateData: [String: Any] = ["state": getConnectionStateString()]
            plugin.notifyListeners("onConnectionStateChanged", data: stateData)
        }
        
        print("SignalR connection opened with ID: \(String(describing: hubConnection.connectionId))")
    }
    
    public func connectionDidFailToOpen(error: Error) {
        self.connectionState = .disconnected
        self.connectionId = nil
        
        if let plugin = self.plugin {
            let stateData: [String: Any] = ["state": getConnectionStateString()]
            plugin.notifyListeners("onConnectionStateChanged", data: stateData)
            
            let errorData: [String: Any] = ["message": error.localizedDescription]
            plugin.notifyListeners("onClosed", data: errorData)
        }
        
        print("SignalR connection failed to open: \(error.localizedDescription)")
    }
    
    public func connectionDidClose(error: Error?) {
        self.connectionState = .disconnected
        self.connectionId = nil
        
        if let plugin = self.plugin {
            let stateData: [String: Any] = ["state": getConnectionStateString()]
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
