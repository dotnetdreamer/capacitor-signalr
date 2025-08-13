import type { PluginListenerHandle } from '@capacitor/core';

export enum ConnectionState {
  CONNECTED = 'connected',
  CONNECTING = 'connecting',
  DISCONNECTED = 'disconnected',
  DISCONNECTING = 'disconnecting',
  RECONNECTING = 'reconnecting'
}

export enum TransportType {
  WEBSOCKETS = 'WEBSOCKETS',
  LONG_POLLING = 'LONG_POLLING',
  SERVER_SENT_EVENTS = 'SERVER_SENT_EVENTS',
  ALL = 'ALL'
}

export interface ConnectionOptions {
  url: string;
  accessToken?: string;
  shouldSkipNegotiate?: boolean;
  skipNegotiation?: boolean;
  headers?: Array<{ name: string; value: string }> | Record<string, string>;
  handshakeResponseTimeout?: number;
  keepAliveInterval?: number;
  serverTimeout?: number;
  transport?: TransportType;
  reconnect?: boolean;
  logLevel?: string;
  enableAutoReconnect?: boolean;
  autoReconnectRetryDelays?: number[];
}

export interface ConnectionInfo {
  connectionId?: string;
  state: ConnectionState;
}

export interface SignalREvent {
  eventName: string;
  data?: any;
}

export interface CapacitorSignalRPlugin {
  /**
   * Create and start a SignalR connection
   */
  create(options: ConnectionOptions): Promise<ConnectionInfo>;
  
  /**
   * Disconnect from the SignalR hub
   */
  disconnect(): Promise<void>;
  
  /**
   * Get the current connection ID
   */
  getConnectionId(): Promise<{ connectionId?: string }>;
  
  /**
   * Get the current connection state
   */
  getConnectionState(): Promise<{ state: ConnectionState }>;
  
  /**
   * Send a message to the SignalR hub
   */
  invoke(options: { methodName: string; args?: any[] }): Promise<void>;
  
  /**
   * Send a message to the SignalR hub and expect a response
   */
  invokeWithResult<T = any>(options: { methodName: string; args?: any[] }): Promise<{ result: T }>;
  
  /**
   * Subscribe to a hub method
   */
  on(options: { eventName: string }): Promise<void>;
  
  /**
   * Unsubscribe from a hub method
   */
  off(options: { eventName: string }): Promise<void>;
  
  /**
   * Add listener for plugin events
   */
  addListener(eventName: 'onReceive', listenerFunc: (event: SignalREvent) => void): Promise<PluginListenerHandle>;
  
  /**
   * Add listener for connection state changes
   */
  addListener(eventName: 'onConnectionStateChanged', listenerFunc: (state: { state: ConnectionState }) => void): Promise<PluginListenerHandle>;
  
  /**
   * Add listener for connection closed event
   */
  addListener(eventName: 'onClosed', listenerFunc: (error?: { error?: string }) => void): Promise<PluginListenerHandle>;
  
  /**
   * Add listener for reconnecting event
   */
  addListener(eventName: 'onReconnecting', listenerFunc: (error?: { error?: string }) => void): Promise<PluginListenerHandle>;
  
  /**
   * Add listener for reconnected event
   */
  addListener(eventName: 'onReconnected', listenerFunc: (info: { connectionId?: string }) => void): Promise<PluginListenerHandle>;

  /**
   * Remove all listeners for this plugin
   */
  removeAllListeners(): Promise<void>;
}
