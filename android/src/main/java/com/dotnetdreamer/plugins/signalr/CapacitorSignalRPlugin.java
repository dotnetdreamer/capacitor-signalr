package com.dotnetdreamer.plugins.signalr;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.util.concurrent.CompletableFuture;

@CapacitorPlugin(name = "CapacitorSignalR")
public class CapacitorSignalRPlugin extends Plugin {

    private CapacitorSignalR implementation = new CapacitorSignalR();

    @Override
    public void load() {
        implementation.setPlugin(this);
    }

    public void notifyListenersPublic(String eventName, JSObject data) {
        notifyListeners(eventName, data);
    }

    @PluginMethod
    public void create(PluginCall call) {
        try {
            JSObject options = call.getData();
            implementation.create(options);
            
            // Start the connection
            CompletableFuture<JSObject> startFuture = implementation.start();
            
            startFuture.whenComplete((result, throwable) -> {
                if (throwable != null) {
                    call.reject("Failed to create connection: " + throwable.getMessage());
                } else {
                    call.resolve(result);
                }
            });
            
        } catch (Exception e) {
            call.reject("Error creating SignalR connection: " + e.getMessage());
        }
    }

    @PluginMethod
    public void disconnect(PluginCall call) {
        try {
            implementation.disconnect();
            call.resolve();
        } catch (Exception e) {
            call.reject("Error disconnecting: " + e.getMessage());
        }
    }

    @PluginMethod
    public void getConnectionId(PluginCall call) {
        try {
            String connectionId = implementation.getConnectionId();
            JSObject result = new JSObject();
            result.put("connectionId", connectionId);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Error getting connection ID: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void getConnectionState(PluginCall call) {
        try {
            String state = implementation.getConnectionState();
            JSObject result = new JSObject();
            result.put("state", state);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Error getting connection state: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void invoke(PluginCall call) {
        try {
            String methodName = call.getString("methodName");
            if (methodName == null) {
                call.reject("Method name is required");
                return;
            }
            
            implementation.invoke(methodName, call.getData().getJSONArray("args"));
            call.resolve();
        } catch (Exception e) {
            call.reject("Error invoking method: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void invokeWithResult(PluginCall call) {
        try {
            String methodName = call.getString("methodName");
            if (methodName == null) {
                call.reject("Method name is required");
                return;
            }
            
            CompletableFuture<Object> invokeFuture = implementation.invokeWithResult(methodName, call.getData().getJSONArray("args"));
            
            invokeFuture.whenComplete((result, throwable) -> {
                if (throwable != null) {
                    call.reject("Error invoking method: " + throwable.getMessage());
                } else {
                    JSObject response = new JSObject();
                    response.put("result", result);
                    call.resolve(response);
                }
            });
            
        } catch (Exception e) {
            call.reject("Error invoking method with result: " + e.getMessage());
        }
    }

    @PluginMethod
    public void on(PluginCall call) {
        try {
            String eventName = call.getString("eventName");
            if (eventName == null) {
                call.reject("Event name is required");
                return;
            }
            
            implementation.on(eventName);
            call.resolve();
        } catch (Exception e) {
            call.reject("Error subscribing to event: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void off(PluginCall call) {
        try {
            String eventName = call.getString("eventName");
            if (eventName == null) {
                call.reject("Event name is required");
                return;
            }
            
            implementation.off(eventName);
            call.resolve();
        } catch (Exception e) {
            call.reject("Error unsubscribing from event: " + e.getMessage(), e);
        }
    }
}
