import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorSignalRPlugin)
public class CapacitorSignalRPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CapacitorSignalRPlugin"
    public let jsName = "CapacitorSignalR"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "create", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "disconnect", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getConnectionId", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getConnectionState", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "invoke", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "invokeWithResult", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "on", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "off", returnType: CAPPluginReturnPromise)
    ]
    
    private let implementation = CapacitorSignalR()

    public override func load() {
        implementation.setPlugin(self)
    }

    @objc func create(_ call: CAPPluginCall) {
        do {
            let _ = try implementation.create(options: call.options as? [String: Any] ?? [:])
            
            // Start the connection
            implementation.start { [weak self] success, error, result in
                DispatchQueue.main.async {
                    if success, let result = result {
                        call.resolve(result)
                    } else {
                        call.reject(error ?? "Failed to start connection")
                    }
                }
            }
            
        } catch {
            call.reject("Error creating SignalR connection: \(error.localizedDescription)")
        }
    }

    @objc func disconnect(_ call: CAPPluginCall) {
        implementation.disconnect()
        call.resolve()
    }

    @objc func getConnectionId(_ call: CAPPluginCall) {
        let connectionId = implementation.getConnectionId()
        call.resolve(["connectionId": connectionId as Any])
    }

    @objc func getConnectionState(_ call: CAPPluginCall) {
        let state = implementation.getConnectionState()
        call.resolve(["state": state])
    }

    @objc func invoke(_ call: CAPPluginCall) {
        guard let methodName = call.getString("methodName") else {
            call.reject("Method name is required")
            return
        }
        
        let args = call.getArray("args", Any.self) ?? []
        
        do {
            try implementation.invoke(methodName: methodName, args: args)
            call.resolve()
        } catch {
            call.reject("Error invoking method: \(error.localizedDescription)")
        }
    }

    @objc func invokeWithResult(_ call: CAPPluginCall) {
        guard let methodName = call.getString("methodName") else {
            call.reject("Method name is required")
            return
        }
        
        let args = call.getArray("args", Any.self) ?? []
        
        implementation.invokeWithResult(methodName: methodName, args: args) { success, result, error in
            DispatchQueue.main.async {
                if success {
                    call.resolve(["result": result as Any])
                } else {
                    call.reject(error ?? "Unknown error occurred")
                }
            }
        }
    }

    @objc func on(_ call: CAPPluginCall) {
        guard let eventName = call.getString("eventName") else {
            call.reject("Event name is required")
            return
        }
        
        do {
            try implementation.on(eventName: eventName)
            call.resolve()
        } catch {
            call.reject("Error subscribing to event: \(error.localizedDescription)")
        }
    }

    @objc func off(_ call: CAPPluginCall) {
        guard let eventName = call.getString("eventName") else {
            call.reject("Event name is required")
            return
        }
        
        implementation.off(eventName: eventName)
        call.resolve()
    }
}
