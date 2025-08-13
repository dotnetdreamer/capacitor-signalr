package com.dotnetdreamer.plugins.signalr;

import android.util.Log;
import com.microsoft.signalr.*;
import com.google.gson.Gson;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import io.reactivex.rxjava3.core.Single;
import io.reactivex.rxjava3.functions.Supplier;
import io.reactivex.rxjava3.functions.Action;
import io.reactivex.rxjava3.functions.Consumer;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

public class CapacitorSignalR {
    private static final String TAG = "CapacitorSignalR";
    private HubConnection hubConnection;
    private String connectionId;
    private HubConnectionState currentState = HubConnectionState.DISCONNECTED;
    private CapacitorSignalRPlugin plugin;
    private final Map<String, Subscription> eventSubscriptions = new HashMap<>();

    public void setPlugin(CapacitorSignalRPlugin plugin) {
        this.plugin = plugin;
    }

    public void create(JSObject options) {
        try {
            String url = options.getString("url");
            if (url == null) {
                throw new IllegalArgumentException("URL is required");
            }

            HttpHubConnectionBuilder builder = HubConnectionBuilder.create(url);

            // Configure access token
            if (options.has("accessToken") && options.getString("accessToken") != null) {
                String accessToken = options.getString("accessToken");
                builder.withAccessTokenProvider(
                    Single.defer(new Supplier<Single<String>>() {
                        @Override
                        public Single<String> get() {
                            return Single.just(accessToken);
                        }
                    })
                );
            }

            // Configure skip negotiate
            if (options.has("shouldSkipNegotiate")) {
                builder.shouldSkipNegotiate(options.getBool("shouldSkipNegotiate"));
            }

            // Configure headers
            if (options.has("headers")) {
                try {
                    JSONArray headersJson = options.getJSONArray("headers");
                    if (headersJson != null) {
                        Map<String, String> headersMap = new HashMap<>();
                        for (int i = 0; i < headersJson.length(); i++) {
                            try {
                                JSONObject header = headersJson.getJSONObject(i);
                                if (header != null) {
                                    String name = header.optString("name");
                                    String value = header.optString("value");
                                    if (name != null && value != null && !name.isEmpty()) {
                                        headersMap.put(name, value);
                                    }
                                }
                            } catch (Exception headerException) {
                                Log.w(TAG, "Error processing header at index " + i, headerException);
                            }
                        }
                        if (!headersMap.isEmpty()) {
                            builder.withHeaders(headersMap);
                        }
                    }
                } catch (Exception e) {
                    Log.w(TAG, "Error processing headers", e);
                }
            }

            // Configure timeouts
            if (options.has("handshakeResponseTimeout")) {
                builder.withHandshakeResponseTimeout(options.getInt("handshakeResponseTimeout"));
            }
            if (options.has("keepAliveInterval")) {
                builder.withKeepAliveInterval(options.getInt("keepAliveInterval"));
            }
            if (options.has("serverTimeout")) {
                builder.withServerTimeout(options.getInt("serverTimeout"));
            }

            // Configure transport
            if (options.has("transport")) {
                String transport = options.getString("transport");
                TransportEnum transportEnum = TransportEnum.WEBSOCKETS; // default
                if ("ALL".equals(transport)) {
                    transportEnum = TransportEnum.ALL;
                } else if ("LONG_POLLING".equals(transport)) {
                    transportEnum = TransportEnum.LONG_POLLING;
                } else if ("WEBSOCKETS".equals(transport)) {
                    transportEnum = TransportEnum.WEBSOCKETS;
                }
                builder.withTransport(transportEnum);
            }

            // Build the connection
            hubConnection = builder.build();
            
            // Set up connection state monitoring
            setupConnectionCallbacks();

        } catch (Exception e) {
            Log.e(TAG, "Error creating SignalR connection", e);
            throw new RuntimeException("Failed to create SignalR connection: " + e.getMessage());
        }
    }

    private void setupConnectionCallbacks() {
        if (hubConnection == null) return;

        // Monitor connection state changes and handle reconnection
        hubConnection.onClosed(new OnClosedCallback() {
            @Override
            public void invoke(Exception exception) {
                currentState = hubConnection.getConnectionState();
                connectionId = null;
                
                if (plugin != null) {
                    JSObject stateData = new JSObject();
                    stateData.put("state", getConnectionStateString(currentState));
                    plugin.notifyListenersPublic("onConnectionStateChanged", stateData);
                    
                    JSObject closedData = new JSObject();
                    if (exception != null) {
                        closedData.put("message", exception.getMessage());
                    }
                    plugin.notifyListenersPublic("onClosed", closedData);
                }
                
                Log.d(TAG, "Connection closed. State: " + currentState);
            }
        });
    }

    public CompletableFuture<JSObject> start() {
        if (hubConnection == null) {
            CompletableFuture<JSObject> future = new CompletableFuture<>();
            future.completeExceptionally(new RuntimeException("Connection not initialized"));
            return future;
        }

        CompletableFuture<JSObject> resultFuture = new CompletableFuture<>();

        try {
            hubConnection.start().subscribe(
                new Action() {
                    @Override
                    public void run() {
                        currentState = hubConnection.getConnectionState();
                        connectionId = hubConnection.getConnectionId();
                        
                        JSObject result = new JSObject();
                        result.put("connectionId", connectionId);
                        result.put("state", getConnectionStateString(currentState));
                        
                        if (plugin != null) {
                            JSObject stateData = new JSObject();
                            stateData.put("state", getConnectionStateString(currentState));
                            plugin.notifyListenersPublic("onConnectionStateChanged", stateData);
                        }
                        
                        resultFuture.complete(result);
                        Log.d(TAG, "Connection started successfully. ID: " + connectionId);
                    }
                },
                new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) {
                        Log.e(TAG, "Failed to start connection", throwable);
                        resultFuture.completeExceptionally(throwable);
                    }
                }
            );
        } catch (Exception e) {
            Log.e(TAG, "Error starting connection", e);
            resultFuture.completeExceptionally(e);
        }

        return resultFuture;
    }

    public void disconnect() {
        if (hubConnection != null && currentState == HubConnectionState.CONNECTED) {
            try {
                hubConnection.stop();
                Log.d(TAG, "Connection stopped");
            } catch (Exception e) {
                Log.e(TAG, "Error stopping connection", e);
            }
        }
    }

    public String getConnectionId() {
        return connectionId;
    }

    public String getConnectionState() {
        return getConnectionStateString(currentState);
    }

    public void invoke(String methodName, JSONArray args) {
        if (hubConnection == null || currentState != HubConnectionState.CONNECTED) {
            throw new RuntimeException("Not connected to SignalR hub");
        }

        try {
            Object[] argsArray = convertJSONArrayToObjectArray(args);
            hubConnection.send(methodName, argsArray);
            Log.d(TAG, "Invoked method: " + methodName);
        } catch (Exception e) {
            Log.e(TAG, "Error invoking method: " + methodName, e);
            throw new RuntimeException("Failed to invoke method: " + e.getMessage());
        }
    }

    public CompletableFuture<Object> invokeWithResult(String methodName, JSONArray args) {
        if (hubConnection == null || currentState != HubConnectionState.CONNECTED) {
            CompletableFuture<Object> future = new CompletableFuture<>();
            future.completeExceptionally(new RuntimeException("Not connected to SignalR hub"));
            return future;
        }

        try {
            Object[] argsArray = convertJSONArrayToObjectArray(args);
            Single<Object> single = hubConnection.invoke(Object.class, methodName, argsArray);
            CompletableFuture<Object> future = new CompletableFuture<>();
            
            single.subscribe(
                new Consumer<Object>() {
                    @Override
                    public void accept(Object result) {
                        future.complete(result);
                    }
                },
                new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) {
                        future.completeExceptionally(throwable);
                    }
                }
            );
            
            return future;
        } catch (Exception e) {
            Log.e(TAG, "Error invoking method with result: " + methodName, e);
            CompletableFuture<Object> future = new CompletableFuture<>();
            future.completeExceptionally(e);
            return future;
        }
    }

    public void on(String eventName) {
        if (hubConnection == null) {
            throw new RuntimeException("Connection not initialized");
        }

        try {
            // Remove existing subscription if any
            off(eventName);
            
            Subscription subscription;
            
            // For the ChatHub, ReceiveMessage sends two parameters: user and message
            if ("ReceiveMessage".equals(eventName)) {
                subscription = hubConnection.on(eventName, 
                    (user, message) -> {
                        // Create an array with both parameters
                        Object[] data = new Object[]{user, message};
                        handleReceivedEvent(eventName, data);
                    }, 
                    String.class, String.class
                );
            } else {
                // For other events that might have different parameter counts
                subscription = hubConnection.on(eventName, 
                    (data) -> {
                        handleReceivedEvent(eventName, data);
                    }, 
                    Object.class
                );
            }
            
            eventSubscriptions.put(eventName, subscription);
            Log.d(TAG, "Subscribed to event: " + eventName);
        } catch (Exception e) {
            Log.e(TAG, "Error subscribing to event: " + eventName, e);
            throw new RuntimeException("Failed to subscribe to event: " + e.getMessage());
        }
    }

    public void off(String eventName) {
        Subscription subscription = eventSubscriptions.remove(eventName);
        if (subscription != null) {
            subscription.unsubscribe();
            Log.d(TAG, "Unsubscribed from event: " + eventName);
        }
    }

    private void handleReceivedEvent(String eventName, Object data) {
        if (plugin != null) {
            JSObject eventData = new JSObject();
            eventData.put("eventName", eventName);
            
            // Convert the received data to a format that can be sent to JavaScript
            if (data != null) {
                try {
                    // Handle array data (like from ReceiveMessage with user and message parameters)
                    if (data instanceof Object[]) {
                        Object[] dataArray = (Object[]) data;
                        JSArray jsArray = new JSArray();
                        for (Object item : dataArray) {
                            jsArray.put(convertToJSCompatible(item));
                        }
                        eventData.put("data", jsArray);
                    } else {
                        eventData.put("data", convertToJSCompatible(data));
                    }
                    
                    Log.d(TAG, "Received SignalR event: " + eventName + " with data: " + eventData.toString());
                } catch (Exception e) {
                    Log.w(TAG, "Error converting event data", e);
                    eventData.put("data", data.toString());
                }
            }
            
            plugin.notifyListenersPublic("onReceive", eventData);
        }
    }

    private Object convertToJSCompatible(Object data) {
        if (data == null) return null;
        
        // Handle common Java types that can be serialized to JSON
        if (data instanceof String || data instanceof Number || data instanceof Boolean) {
            return data;
        }
        
        // For complex objects, try to serialize with Gson and then parse as JSON
        try {
            Gson gson = new Gson();
            String jsonString = gson.toJson(data);
            
            if (jsonString.startsWith("{")) {
                return new JSONObject(jsonString);
            } else if (jsonString.startsWith("[")) {
                return new JSONArray(jsonString);
            } else {
                return jsonString;
            }
        } catch (Exception e) {
            Log.w(TAG, "Failed to serialize data, returning string representation", e);
            return data.toString();
        }
    }

    private Object[] convertJSArrayToObjectArray(JSArray jsArray) {
        if (jsArray == null) return new Object[0];
        
        try {
            Object[] result = new Object[jsArray.length()];
            for (int i = 0; i < jsArray.length(); i++) {
                result[i] = jsArray.get(i);
            }
            return result;
        } catch (Exception e) {
            Log.w(TAG, "Error converting JSArray to Object[]", e);
            return new Object[0];
        }
    }

    private Object[] convertJSONArrayToObjectArray(JSONArray jsonArray) {
        if (jsonArray == null) return new Object[0];
        
        try {
            Object[] result = new Object[jsonArray.length()];
            for (int i = 0; i < jsonArray.length(); i++) {
                result[i] = jsonArray.get(i);
            }
            return result;
        } catch (Exception e) {
            Log.w(TAG, "Error converting JSONArray to Object[]", e);
            return new Object[0];
        }
    }

    private String getConnectionStateString(HubConnectionState state) {
        if (state == null) return "disconnected";
        
        switch (state) {
            case CONNECTED:
                return "connected";
            case CONNECTING:
                return "connecting";
            case DISCONNECTED:
            default:
                return "disconnected";
        }
    }
}
