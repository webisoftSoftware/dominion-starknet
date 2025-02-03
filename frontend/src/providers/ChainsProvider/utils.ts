import React from 'react';
import { ChainClient, WalletAccount } from '@frontend/chains/types';

export const WalletContext = React.createContext<{
  wallet: WalletAccount | null;
  client: ChainClient | null;
}>({ wallet: null, client: null });

export function useWallet(): WalletAccount | null {
  const { wallet } = React.useContext(WalletContext);
  return wallet;
}

export function useChainClient(): ChainClient | null {
  const { client } = React.useContext(WalletContext);
  return client;
}
