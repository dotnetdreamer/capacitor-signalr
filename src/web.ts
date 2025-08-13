import { WebPlugin } from '@capacitor/core';
import * as signalR from '@microsoft/signalr';

import type { 
  CapacitorSignalRPlugin, 
  ConnectionOptions, 
  ConnectionInfo, 
  SignalREvent
} from './definitions';

import { ConnectionState, TransportType } from './definitions';

export class CapacitorSignalRWeb extends WebPlugin implements CapacitorSignalRPlugin {
  private hubConnection?: signalR.HubConnection;
  private connectionState: ConnectionState = ConnectionState.DISCONNECTED;
  private eventHandlers: Map<string, (...args: any[]) => void> = new Map();

  private getTransportType(transportType?: TransportType): signalR.HttpTransportType {
    switch (transportType) {
      case TransportType.WEBSOCKETS:
        return signalR.HttpTransportType.WebSockets;
      case TransportType.SERVER_SENT_EVENTS:
        return signalR.HttpTransportType.ServerSentEvents;
      case TransportType.LONG_POLLING:
        return signalR.HttpTransportType.LongPolling;
      default:
        return signalR.HttpTransportType.WebSockets | signalR.HttpTransportType.ServerSentEvents | signalR.HttpTransportType.LongPolling;
    }
  }

  private getLogLevel(logLevel?: string): signalR.LogLevel {
    switch (logLevel?.toLowerCase()) {
      case 'trace':
        return signalR.LogLevel.Trace;
      case 'debug':
        return signalR.LogLevel.Debug;
      case 'information':
        return signalR.LogLevel.Information;
      case 'warning':
        return signalR.LogLevel.Warning;
      case 'error':
        return signalR.LogLevel.Error;
      case 'critical':
        return signalR.LogLevel.Critical;
      case 'none':
        return signalR.LogLevel.None;
      default:
        return signalR.LogLevel.Information;
    }
  }

  private updateConnectionState(state: ConnectionState): void {
    if (this.connectionState !== state) {
      this.connectionState = state;
      this.notifyListeners('onConnectionStateChanged', { state });
    }
  }

  private convertHeaders(headers?: Array<{ name: string; value: string }> | Record<string, string>): Record<string, string> | undefined {
    if (!headers) return undefined;
    
    if (Array.isArray(headers)) {
      const result: Record<string, string> = {};
      headers.forEach(header => {
        result[header.name] = header.value;
      });
      return result;
    }
    
    return headers;
  }

  async create(options: ConnectionOptions): Promise<ConnectionInfo> {
    console.log('SignalR Web: create() called with options:', options);
    
    try {
      // Create the connection builder
      const connectionBuilder = new signalR.HubConnectionBuilder()
        .withUrl(options.url, {
          transport: this.getTransportType(options.transport),
          skipNegotiation: options.skipNegotiation || options.shouldSkipNegotiate || false,
          headers: this.convertHeaders(options.headers),
          accessTokenFactory: options.accessToken ? () => options.accessToken! : undefined,
        })
        .configureLogging(this.getLogLevel(options.logLevel));

      // Configure automatic reconnect if specified
      if (options.enableAutoReconnect) {
        const retryDelays = options.autoReconnectRetryDelays || [0, 2000, 10000, 30000];
        connectionBuilder.withAutomaticReconnect(retryDelays);
      }

      // Build the connection
      this.hubConnection = connectionBuilder.build();

      // Set up event handlers
      this.setupEventHandlers();

      this.updateConnectionState(ConnectionState.CONNECTING);

      // Start the connection
      await this.hubConnection.start();
      
      this.updateConnectionState(ConnectionState.CONNECTED);

      const connectionInfo: ConnectionInfo = {
        connectionId: this.hubConnection.connectionId || undefined,
        state: this.connectionState
      };

      console.log('SignalR Web: Connected successfully', connectionInfo);
      return connectionInfo;

    } catch (error) {
      this.updateConnectionState(ConnectionState.DISCONNECTED);
      console.error('SignalR Web: Connection failed:', error);
      throw error;
    }
  }

  private setupEventHandlers(): void {
    if (!this.hubConnection) return;

    // Connection state handlers
    this.hubConnection.onclose((error) => {
      this.updateConnectionState(ConnectionState.DISCONNECTED);
      this.notifyListeners('onClosed', { error: error?.message });
    });

    this.hubConnection.onreconnecting((error) => {
      this.updateConnectionState(ConnectionState.RECONNECTING);
      this.notifyListeners('onReconnecting', { error: error?.message });
    });

    this.hubConnection.onreconnected((connectionId) => {
      this.updateConnectionState(ConnectionState.CONNECTED);
      this.notifyListeners('onReconnected', { connectionId });
    });
  }

  async disconnect(): Promise<void> {
    console.log('SignalR Web: disconnect() called');
    
    if (this.hubConnection) {
      try {
        await this.hubConnection.stop();
      } catch (error) {
        console.error('SignalR Web: Error during disconnect:', error);
      } finally {
        this.hubConnection = undefined;
        this.eventHandlers.clear();
        this.updateConnectionState(ConnectionState.DISCONNECTED);
        this.notifyListeners('onClosed', {});
      }
    }
  }

  async getConnectionId(): Promise<{ connectionId?: string }> {
    return { 
      connectionId: this.hubConnection?.connectionId || undefined 
    };
  }

  async getConnectionState(): Promise<{ state: ConnectionState }> {
    if (this.hubConnection) {
      // Map SignalR connection state to our enum
      switch (this.hubConnection.state) {
        case signalR.HubConnectionState.Connecting:
          this.connectionState = ConnectionState.CONNECTING;
          break;
        case signalR.HubConnectionState.Connected:
          this.connectionState = ConnectionState.CONNECTED;
          break;
        case signalR.HubConnectionState.Reconnecting:
          this.connectionState = ConnectionState.RECONNECTING;
          break;
        case signalR.HubConnectionState.Disconnecting:
          this.connectionState = ConnectionState.DISCONNECTING;
          break;
        case signalR.HubConnectionState.Disconnected:
          this.connectionState = ConnectionState.DISCONNECTED;
          break;
      }
    }
    return { state: this.connectionState };
  }

  async invoke(options: { methodName: string; args?: any[] }): Promise<void> {
    console.log('SignalR Web: invoke() called with:', options);
    
    if (!this.hubConnection || this.connectionState !== ConnectionState.CONNECTED) {
      throw new Error('Not connected to SignalR hub');
    }

    try {
      await this.hubConnection.invoke(options.methodName, ...(options.args || []));
    } catch (error) {
      console.error('SignalR Web: Invoke error:', error);
      throw error;
    }
  }

  async invokeWithResult<T = any>(options: { methodName: string; args?: any[] }): Promise<{ result: T }> {
    console.log('SignalR Web: invokeWithResult() called with:', options);
    
    if (!this.hubConnection || this.connectionState !== ConnectionState.CONNECTED) {
      throw new Error('Not connected to SignalR hub');
    }

    try {
      const result = await this.hubConnection.invoke<T>(options.methodName, ...(options.args || []));
      return { result };
    } catch (error) {
      console.error('SignalR Web: InvokeWithResult error:', error);
      throw error;
    }
  }

  async on(options: { eventName: string }): Promise<void> {
    console.log('SignalR Web: on() called for event:', options.eventName);
    
    if (!this.hubConnection) {
      throw new Error('Hub connection not initialized');
    }

    // Remove existing handler if any
    if (this.eventHandlers.has(options.eventName)) {
      this.hubConnection.off(options.eventName, this.eventHandlers.get(options.eventName)!);
    }

    // Create new handler
    const handler = (...args: any[]) => {
      const event: SignalREvent = { 
        eventName: options.eventName, 
        data: args.length === 1 ? args[0] : args 
      };
      this.notifyListeners('onReceive', event);
    };

    // Register handler
    this.eventHandlers.set(options.eventName, handler);
    this.hubConnection.on(options.eventName, handler);
  }

  async off(options: { eventName: string }): Promise<void> {
    console.log('SignalR Web: off() called for event:', options.eventName);
    
    if (!this.hubConnection) {
      throw new Error('Hub connection not initialized');
    }

    const handler = this.eventHandlers.get(options.eventName);
    if (handler) {
      this.hubConnection.off(options.eventName, handler);
      this.eventHandlers.delete(options.eventName);
    }
  }

  // For testing purposes, we can simulate receiving events
  simulateReceiveEvent(eventName: string, data?: any): void {
    const event: SignalREvent = { eventName, data };
    this.notifyListeners('onReceive', event);
  }
}
