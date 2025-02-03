import { createDojoConfig } from '@dojoengine/core';

import manifest from "../../contracts/manifest_sepolia.json" with {type: "json"};

export const dojoConfig = createDojoConfig({
  rpcUrl: 'https://api.cartridge.gg/x/starknet/sepolia',
  toriiUrl: 'localhost:8080',
  relayUrl: "/ip4/127.0.0.1/tcp/9092/ws",
  manifest,
});
