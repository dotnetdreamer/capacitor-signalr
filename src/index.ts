import { registerPlugin } from '@capacitor/core';

import type { CapacitorSignalRPlugin } from './definitions';

const CapacitorSignalR = registerPlugin<CapacitorSignalRPlugin>('CapacitorSignalR', {
  web: () => import('./web').then((m) => new m.CapacitorSignalRWeb()),
});

export * from './definitions';
export { CapacitorSignalR };
