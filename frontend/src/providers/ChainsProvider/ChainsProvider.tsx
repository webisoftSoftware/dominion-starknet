import React from 'react';

import { Chains } from '@frontend/chains';
import {
  CHAIN_TYPE,
  type ChainClient,
  type ChainDetails,
  ChainType,
  type WalletAccount,
} from '@frontend/chains/types';
import ChainsConnectors from '@frontend/providers/ChainsProvider/ChainsConnectors';
import { StarknetChain } from '@frontend/chains/starknet/types';
import StarknetProvider from './StarknetProvider';

const SELECTED_CHAIN_STORAGE_KEY = 'selected-chain';
const DEFAULT_SELECTED_CHAIN: [ChainType, string] = ['starknet', StarknetChain];

export interface ChainContextValue {
  availableChains: ChainDetails[];
  chain: ChainDetails;
  setChain: (chain: ChainDetails) => void;

  getSignedClient: (account: WalletAccount) => ChainClient;
}

const ChainContext = React.createContext<ChainContextValue | null>(null);

export interface ChainsProviderProps {
  children: React.ReactNode;

  testnets?: boolean;
}

/**
 * Provides all the necessities to set the currently active chain as well as the connectors for wallets
 *
 * @param children
 * @param testnets
 * @constructor
 */
const ChainsProvider = ({ children, testnets = false }: ChainsProviderProps) => {
  const availableChains = React.useMemo(() => {
    return Chains.listChains().filter((chain) => chain.is_testnet === testnets);
  }, [testnets]);

  const [[selectedChainType, selectedChainId], setSelectedChain] = React.useState<[ChainType, string]>(() => {
    const storedSelection = localStorage.getItem(SELECTED_CHAIN_STORAGE_KEY);

    if (storedSelection) {
      const [chainType, chainId] = storedSelection.split('__');

      if (availableChains.find((chainDetails) => chainDetails.type === chainType && chainDetails.id === chainId)) {
        return [chainType as ChainType, chainId!];
      }
    }

    return DEFAULT_SELECTED_CHAIN;
  });

  const selectedChain = React.useMemo(() => {
    return availableChains.find(
      (chainDetails) => chainDetails.type === selectedChainType && chainDetails.id === selectedChainId,
    )!;
  }, [availableChains, selectedChainType, selectedChainId]);

  const handleChangeChain = React.useCallback(
    (newChain: ChainDetails) => {
      // Validate the chain is available
      const chain = availableChains.find(
        (chainDetails) => chainDetails.type === newChain.type && chainDetails.id === newChain.id,
      );

      if (!chain) {
        // Chain not found, do nothing
        return;
      }

      setSelectedChain([chain.type, chain.id]);
      localStorage.setItem(SELECTED_CHAIN_STORAGE_KEY, `${chain.type}__${chain.id}`);
    },
    [availableChains],
  );

  const ctx = React.useMemo<ChainContextValue>(
    () => ({
      availableChains: availableChains,
      chain: selectedChain,
      setChain: handleChangeChain,
      getSignedClient: (account: WalletAccount) => Chains.getClient(selectedChain.type, selectedChain.id, account),
    }),
    [availableChains, handleChangeChain, selectedChain],
  );

  return (
    <ChainContext.Provider value={ctx}>
      <ChainsConnectors>
        {selectedChainType === CHAIN_TYPE.STARKNET ? (
          <StarknetProvider chain={selectedChain}>{children}</StarknetProvider>
        ) : (
          <ChainsConnectors>{children}</ChainsConnectors>
        )}
      </ChainsConnectors>
    </ChainContext.Provider>
  );
};

export default ChainsProvider;

export function useChain(): ChainContextValue {
  return React.useContext(ChainContext)!;
}
