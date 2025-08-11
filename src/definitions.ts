export interface CapacitorSignalRPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
