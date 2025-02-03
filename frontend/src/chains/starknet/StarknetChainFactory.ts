import {
  CHAIN_TYPE,
  type ChainClient,
  type ChainDetails,
  type ChainFactory,
  type WalletAccount,
} from '@frontend/chains/types';
import type { PokerClient } from '@frontend/games/poker/client';
import { NetworkType, StarknetClient } from '@frontend/chains/starknet/StarknetClient';
import { StarknetPokerRoomClient } from '@frontend/games/poker/client/starknet/StarknetPokerRoomClient';
import { StarknetPokerClient } from '@frontend/games/poker/client/starknet/StarknetPokerClient';
import { StarknetChain } from '@frontend/chains/starknet/types';
import { setupWorld } from '@frontend/dojo/contracts';
import { DojoProvider } from '@dojoengine/core';
import { dojoConfig } from '@frontend/dojo/dojoConfig';
import { Account } from 'starknet';
import React from 'react';
import { useAccount } from '@starknet-react/core';
import { useController } from '@frontend/chains/starknet/hooks';
import { useWallet } from '@frontend/providers/ChainsProvider';

function listChains(): string[] {
  return [StarknetChain];
}

function getChainDetails(network: string): ChainDetails {
  // Since there's only one chain on Starknet, treat the network as the network identifier.
  return {
    type: CHAIN_TYPE.STARKNET,
    id: 'starknet',
    name: network,
    icon: "stark",
    is_testnet: network === "sepolia"
  };
}

function getChainClient(chainId: string, account: WalletAccount): StarknetClient {
  const dojoProvider = new DojoProvider(dojoConfig.manifest, dojoConfig.rpcUrl);
  const starknetAccount: Account = new Account(dojoProvider.provider, account.address ?? '', '');
  return new StarknetClient({
    chainIcon: 'stark',
    chainNetwork: chainId === 'sepolia' ? NetworkType.Sepolia : NetworkType.Mainnet,
    rpcEndpoint: `https://api.cartridge.gg/x/starknet/${chainId}`,
    contracts: setupWorld(dojoProvider),
    userAccount: starknetAccount,
  });
}

function getPokerClient(client: ChainClient): StarknetPokerClient | null {
  if (client.getChainType() !== CHAIN_TYPE.STARKNET) {
    throw new Error("invalid client type");
  }
  return new StarknetPokerClient(client as StarknetClient);
}

async function getPokerRoomClient(
  roomId: number,
  pokerClient: PokerClient,
  wallet: WalletAccount,
): Promise<StarknetPokerRoomClient | null> {
  // TODO: Implement this as needed
  return null;
}

function useWalletAccount(chainId: string): WalletAccount {
  const wallet = useWallet();

  const balance = React.useCallback(() => {
    if (!wallet || !wallet.address) {
      return Promise.resolve(0);
    }
    return Promise.resolve(StarknetChainFactory.getChainClient("sepolia", wallet).getBalance(wallet.address));
  }, [wallet?.status]);

  return {
    type: 'starknet',
    chain: chainId,
    address: wallet?.address ?? "",
    username: wallet?.username ?? "",
    status: wallet?.status ?? "error",
    getBalance: balance,
    // eslint-disable-next-line @typescript-eslint/no-empty-function
    connect: wallet ? wallet.connect : () => {},
    // eslint-disable-next-line @typescript-eslint/no-empty-function
    disconnect: wallet ? wallet.disconnect : () => {},
    currencySymbol: 'ETH',
    currencyDecimals: 4,
    walletChainImpl: {},
    walletChainInfo: {}
  };
}

export const StarknetChainFactory: ChainFactory = {
  listChains,
  getChainDetails,
  useWalletAccount,
  getChainRestEndpoint: (chain: string) => '',
  getChainRpcEndpoint: (chain: string) => `https://api.cartridge.gg/x/starknet/${chain}`,
  getChainClient,
  getPokerClient,
  getPokerRoomClient,
};
