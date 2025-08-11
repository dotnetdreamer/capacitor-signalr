import { WebPlugin } from '@capacitor/core';

import type { CapacitorSignalRPlugin } from './definitions';

export class CapacitorSignalRWeb extends WebPlugin implements CapacitorSignalRPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
