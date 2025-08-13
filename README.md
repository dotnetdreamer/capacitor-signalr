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


#### Array

| Prop         | Type                | Description                                                                                            |
| ------------ | ------------------- | ------------------------------------------------------------------------------------------------------ |
| **`length`** | <code>number</code> | Gets or sets the length of the array. This is a number one higher than the highest index in the array. |

| Method             | Signature                                                                                                                     | Description                                                                                                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **toString**       | () =&gt; string                                                                                                               | Returns a string representation of an array.                                                                                                                                                                                                |
| **toLocaleString** | () =&gt; string                                                                                                               | Returns a string representation of an array. The elements are converted to string using their toLocalString methods.                                                                                                                        |
| **pop**            | () =&gt; T \| undefined                                                                                                       | Removes the last element from an array and returns it. If the array is empty, undefined is returned and the array is not modified.                                                                                                          |
| **push**           | (...items: T[]) =&gt; number                                                                                                  | Appends new elements to the end of an array, and returns the new length of the array.                                                                                                                                                       |
| **concat**         | (...items: <a href="#concatarray">ConcatArray</a>&lt;T&gt;[]) =&gt; T[]                                                       | Combines two or more arrays. This method returns a new array without modifying any existing arrays.                                                                                                                                         |
| **concat**         | (...items: (T \| <a href="#concatarray">ConcatArray</a>&lt;T&gt;)[]) =&gt; T[]                                                | Combines two or more arrays. This method returns a new array without modifying any existing arrays.                                                                                                                                         |
| **join**           | (separator?: string \| undefined) =&gt; string                                                                                | Adds all the elements of an array into a string, separated by the specified separator string.                                                                                                                                               |
| **reverse**        | () =&gt; T[]                                                                                                                  | Reverses the elements in an array in place. This method mutates the array and returns a reference to the same array.                                                                                                                        |
| **shift**          | () =&gt; T \| undefined                                                                                                       | Removes the first element from an array and returns it. If the array is empty, undefined is returned and the array is not modified.                                                                                                         |
| **slice**          | (start?: number \| undefined, end?: number \| undefined) =&gt; T[]                                                            | Returns a copy of a section of an array. For both start and end, a negative index can be used to indicate an offset from the end of the array. For example, -2 refers to the second to last element of the array.                           |
| **sort**           | (compareFn?: ((a: T, b: T) =&gt; number) \| undefined) =&gt; this                                                             | Sorts an array in place. This method mutates the array and returns a reference to the same array.                                                                                                                                           |
| **splice**         | (start: number, deleteCount?: number \| undefined) =&gt; T[]                                                                  | Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.                                                                                                                      |
| **splice**         | (start: number, deleteCount: number, ...items: T[]) =&gt; T[]                                                                 | Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.                                                                                                                      |
| **unshift**        | (...items: T[]) =&gt; number                                                                                                  | Inserts new elements at the start of an array, and returns the new length of the array.                                                                                                                                                     |
| **indexOf**        | (searchElement: T, fromIndex?: number \| undefined) =&gt; number                                                              | Returns the index of the first occurrence of a value in an array, or -1 if it is not present.                                                                                                                                               |
| **lastIndexOf**    | (searchElement: T, fromIndex?: number \| undefined) =&gt; number                                                              | Returns the index of the last occurrence of a specified value in an array, or -1 if it is not present.                                                                                                                                      |
| **every**          | &lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any) =&gt; this is S[]       | Determines whether all the members of an array satisfy the specified test.                                                                                                                                                                  |
| **every**          | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; boolean                                 | Determines whether all the members of an array satisfy the specified test.                                                                                                                                                                  |
| **some**           | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; boolean                                 | Determines whether the specified callback function returns true for any element of an array.                                                                                                                                                |
| **forEach**        | (callbackfn: (value: T, index: number, array: T[]) =&gt; void, thisArg?: any) =&gt; void                                      | Performs the specified action for each element in an array.                                                                                                                                                                                 |
| **map**            | &lt;U&gt;(callbackfn: (value: T, index: number, array: T[]) =&gt; U, thisArg?: any) =&gt; U[]                                 | Calls a defined callback function on each element of an array, and returns an array that contains the results.                                                                                                                              |
| **filter**         | &lt;S extends T&gt;(predicate: (value: T, index: number, array: T[]) =&gt; value is S, thisArg?: any) =&gt; S[]               | Returns the elements of an array that meet the condition specified in a callback function.                                                                                                                                                  |
| **filter**         | (predicate: (value: T, index: number, array: T[]) =&gt; unknown, thisArg?: any) =&gt; T[]                                     | Returns the elements of an array that meet the condition specified in a callback function.                                                                                                                                                  |
| **reduce**         | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T) =&gt; T                           | Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.                      |
| **reduce**         | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T) =&gt; T          |                                                                                                                                                                                                                                             |
| **reduce**         | &lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U) =&gt; U | Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.                      |
| **reduceRight**    | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T) =&gt; T                           | Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function. |
| **reduceRight**    | (callbackfn: (previousValue: T, currentValue: T, currentIndex: number, array: T[]) =&gt; T, initialValue: T) =&gt; T          |                                                                                                                                                                                                                                             |
| **reduceRight**    | &lt;U&gt;(callbackfn: (previousValue: U, currentValue: T, currentIndex: number, array: T[]) =&gt; U, initialValue: U) =&gt; U | Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function. |


#### ConcatArray

| Prop         | Type                |
| ------------ | ------------------- |
| **`length`** | <code>number</code> |

| Method    | Signature                                                          |
| --------- | ------------------------------------------------------------------ |
| **join**  | (separator?: string \| undefined) =&gt; string                     |
| **slice** | (start?: number \| undefined, end?: number \| undefined) =&gt; T[] |


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
