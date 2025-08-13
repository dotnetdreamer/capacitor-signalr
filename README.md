# capacitor-signalr

Native signalr plugin for ionic capacitor

## Install

```bash
npm install capacitor-signalr
npx cap sync
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

<code>{ [P in K]: T; }</code>


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
