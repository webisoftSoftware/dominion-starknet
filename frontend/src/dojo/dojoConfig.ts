import { createDojoConfig } from '@dojoengine/core';

import manifest from "./manifest_sepolia.json";

export const dojoConfig = createDojoConfig({
  rpcUrl: 'https://api.cartridge.gg/x/starknet/sepolia',
  toriiUrl: 'http://localhost:8080',
  relayUrl: "/ip4/127.0.0.1/tcp/9092/ws",
  manifest,
});
