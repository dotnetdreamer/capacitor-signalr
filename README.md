# Capacitor SignalR

A Capacitor plugin that provides native SignalR client functionality for iOS and Android with web fallback support.


https://github.com/user-attachments/assets/b13fde4b-b8fe-4cc9-acc6-c3f797ef0d57



## 📱 Demo App

Want to see the plugin in action? Check out our **[Demo Repository](https://github.com/dotnetdreamer/capacitor-signalr-demo)** that showcases real-time chat functionality with complete setup instructions.

### Demo Features
- ✅ Real-time bidirectional messaging between mobile and web clients
- ✅ Connection state monitoring
- ✅ Auto-reconnection handling
- ✅ Cross-platform compatibility testing
- ✅ Complete ASP.NET Core SignalR backend
- ✅ Ionic Angular mobile client
- ✅ Web client for testing

**👉 [Get the Demo App](https://github.com/dotnetdreamer/capacitor-signalr-demo)**

---

## Key Features
- 🚀 Native performance on iOS and Android
- 🔄 Real-time bidirectional communication
- 🌐 Multiple transport protocols (WebSockets, SSE, Long Polling)
- 🔐 Authentication and custom headers support
- ⚡ Auto-reconnection with configurable retry delays
- 📱 Cross-platform compatibility (iOS, Android, Web)
- 🎯 TypeScript support with full type definitions

## Install

```bash
npm install capacitor-signalr
npx cap sync
```

## Quick Start

```typescript
import { CapacitorSignalR, ConnectionState, TransportType } from 'capacitor-signalr';

// Create connection
const connection = await CapacitorSignalR.create({
  url: 'https://your-signalr-hub.com/chatHub',
  enableAutoReconnect: true,
  transport: TransportType.ALL,
  logLevel: 'Information'
});

// Listen for messages
await CapacitorSignalR.addListener('onReceive', (event) => {
  if (event.eventName === 'ReceiveMessage') {
    console.log('Received:', event.data);
  }
});

// Subscribe to hub methods
await CapacitorSignalR.on({ eventName: 'ReceiveMessage' });

// Send messages
await CapacitorSignalR.invoke({
  methodName: 'SendMessage',
  args: ['username', 'Hello World!']
});

// Monitor connection state
await CapacitorSignalR.addListener('onConnectionStateChanged', (state) => {
  console.log('Connection state:', state.state);
});
```

## API

<docgen-index>

* [`create(...)`](#create)
* [`disconnect()`](#disconnect)
* [`getConnectionId()`](#getconnectionid)
* [`getConnectionState()`](#getconnectionstate)
* [`invoke(...)`](#invoke)
* [`invokeWithResult(...)`](#invokewithresult)
* [`on(...)`](#on)
* [`off(...)`](#off)
* [`addListener('onReceive', ...)`](#addlisteneronreceive-)
* [`addListener('onConnectionStateChanged', ...)`](#addlisteneronconnectionstatechanged-)
* [`addListener('onClosed', ...)`](#addlisteneronclosed-)
* [`addListener('onReconnecting', ...)`](#addlisteneronreconnecting-)
* [`addListener('onReconnected', ...)`](#addlisteneronreconnected-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### create(...)

```typescript
create(options: ConnectionOptions) => Promise<ConnectionInfo>
```

Create and start a SignalR connection

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#connectionoptions">ConnectionOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#connectioninfo">ConnectionInfo</a>&gt;</code>

--------------------


### disconnect()

```typescript
disconnect() => Promise<void>
```

Disconnect from the SignalR hub

--------------------


### getConnectionId()

```typescript
getConnectionId() => Promise<{ connectionId?: string; }>
```

Get the current connection ID

**Returns:** <code>Promise&lt;{ connectionId?: string; }&gt;</code>

--------------------


### getConnectionState()

```typescript
getConnectionState() => Promise<{ state: ConnectionState; }>
```

Get the current connection state

**Returns:** <code>Promise&lt;{ state: <a href="#connectionstate">ConnectionState</a>; }&gt;</code>

--------------------


### invoke(...)

```typescript
invoke(options: { methodName: string; args?: any[]; }) => Promise<void>
```

Send a message to the SignalR hub

| Param         | Type                                               |
| ------------- | -------------------------------------------------- |
| **`options`** | <code>{ methodName: string; args?: any[]; }</code> |

--------------------


### invokeWithResult(...)

```typescript
invokeWithResult<T = any>(options: { methodName: string; args?: any[]; }) => Promise<{ result: T; }>
```

Send a message to the SignalR hub and expect a response

| Param         | Type                                               |
| ------------- | -------------------------------------------------- |
| **`options`** | <code>{ methodName: string; args?: any[]; }</code> |

**Returns:** <code>Promise&lt;{ result: T; }&gt;</code>

--------------------


### on(...)

```typescript
on(options: { eventName: string; }) => Promise<void>
```

Subscribe to a hub method

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ eventName: string; }</code> |

--------------------


### off(...)

```typescript
off(options: { eventName: string; }) => Promise<void>
```

Unsubscribe from a hub method

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ eventName: string; }</code> |

--------------------


### addListener('onReceive', ...)

```typescript
addListener(eventName: 'onReceive', listenerFunc: (event: SignalREvent) => void) => Promise<PluginListenerHandle>
```

Add listener for plugin events

| Param              | Type                                                                      |
| ------------------ | ------------------------------------------------------------------------- |
| **`eventName`**    | <code>'onReceive'</code>                                                  |
| **`listenerFunc`** | <code>(event: <a href="#signalrevent">SignalREvent</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onConnectionStateChanged', ...)

```typescript
addListener(eventName: 'onConnectionStateChanged', listenerFunc: (state: { state: ConnectionState; }) => void) => Promise<PluginListenerHandle>
```

Add listener for connection state changes

| Param              | Type                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'onConnectionStateChanged'</code>                                                     |
| **`listenerFunc`** | <code>(state: { state: <a href="#connectionstate">ConnectionState</a>; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onClosed', ...)

```typescript
addListener(eventName: 'onClosed', listenerFunc: (error?: { error?: string | undefined; } | undefined) => void) => Promise<PluginListenerHandle>
```

Add listener for connection closed event

| Param              | Type                                                  |
| ------------------ | ----------------------------------------------------- |
| **`eventName`**    | <code>'onClosed'</code>                               |
| **`listenerFunc`** | <code>(error?: { error?: string; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onReconnecting', ...)

```typescript
addListener(eventName: 'onReconnecting', listenerFunc: (error?: { error?: string | undefined; } | undefined) => void) => Promise<PluginListenerHandle>
```

Add listener for reconnecting event

| Param              | Type                                                  |
| ------------------ | ----------------------------------------------------- |
| **`eventName`**    | <code>'onReconnecting'</code>                         |
| **`listenerFunc`** | <code>(error?: { error?: string; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onReconnected', ...)

```typescript
addListener(eventName: 'onReconnected', listenerFunc: (info: { connectionId?: string; }) => void) => Promise<PluginListenerHandle>
```

Add listener for reconnected event

| Param              | Type                                                       |
| ------------------ | ---------------------------------------------------------- |
| **`eventName`**    | <code>'onReconnected'</code>                               |
| **`listenerFunc`** | <code>(info: { connectionId?: string; }) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

Remove all listeners for this plugin

--------------------


### Interfaces


#### ConnectionInfo

| Prop               | Type                                                        |
| ------------------ | ----------------------------------------------------------- |
| **`connectionId`** | <code>string</code>                                         |
| **`state`**        | <code><a href="#connectionstate">ConnectionState</a></code> |


#### ConnectionOptions

| Prop                           | Type                                                                                                  |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- |
| **`url`**                      | <code>string</code>                                                                                   |
| **`accessToken`**              | <code>string</code>                                                                                   |
| **`shouldSkipNegotiate`**      | <code>boolean</code>                                                                                  |
| **`skipNegotiation`**          | <code>boolean</code>                                                                                  |
| **`headers`**                  | <code>{ name: string; value: string; }[] \| <a href="#record">Record</a>&lt;string, string&gt;</code> |
| **`handshakeResponseTimeout`** | <code>number</code>                                                                                   |
| **`keepAliveInterval`**        | <code>number</code>                                                                                   |
| **`serverTimeout`**            | <code>number</code>                                                                                   |
| **`transport`**                | <code><a href="#transporttype">TransportType</a></code>                                               |
| **`reconnect`**                | <code>boolean</code>                                                                                  |
| **`logLevel`**                 | <code>string</code>                                                                                   |
| **`enableAutoReconnect`**      | <code>boolean</code>                                                                                  |
| **`autoReconnectRetryDelays`** | <code>number[]</code>                                                                                 |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### SignalREvent

| Prop            | Type                |
| --------------- | ------------------- |
| **`eventName`** | <code>string</code> |
| **`data`**      | <code>any</code>    |


### Type Aliases


#### Record

Construct a type with a set of properties K of type T

<code>{
 [P in K]: T;
 }</code>


### Enums


#### ConnectionState

| Members             | Value                        |
| ------------------- | ---------------------------- |
| **`CONNECTED`**     | <code>'connected'</code>     |
| **`CONNECTING`**    | <code>'connecting'</code>    |
| **`DISCONNECTED`**  | <code>'disconnected'</code>  |
| **`DISCONNECTING`** | <code>'disconnecting'</code> |
| **`RECONNECTING`**  | <code>'reconnecting'</code>  |


#### TransportType

| Members                  | Value                             |
| ------------------------ | --------------------------------- |
| **`WEBSOCKETS`**         | <code>'WEBSOCKETS'</code>         |
| **`LONG_POLLING`**       | <code>'LONG_POLLING'</code>       |
| **`SERVER_SENT_EVENTS`** | <code>'SERVER_SENT_EVENTS'</code> |
| **`ALL`**                | <code>'ALL'</code>                |

</docgen-api>
