import { ChainDetails } from '@frontend/chains/types';
import React, { useMemo } from 'react';
import { DojoWrapper } from '@frontend/chains/starknet/DojoWrapper';
import {
  StarknetConfig,
  jsonRpcProvider,
} from '@starknet-react/core';

import { sepolia, mainnet } from '@starknet-react/chains';
import { dojoConfig } from '@frontend/dojo/dojoConfig';
import { ControllerProvider } from '@frontend/chains/starknet/ControllerContext';
import { useController } from '@frontend/chains/starknet/hooks';
import { StarknetChainFactory } from '@frontend/chains/starknet/StarknetChainFactory';
import { WalletContext } from '@frontend/providers/ChainsProvider/utils';
import { ControllerConnector } from '@cartridge/connector';
import { constants } from 'starknet';
import { ACTIONS_CONTRACT_ADDRESS, CASHIER_CONTRACT_ADDRESS, } from '@frontend/games/poker/client/starknet/StarknetPokerRoomClient';

interface StarknetProviderProps {
  chain: ChainDetails;
  children: React.ReactNode;
}

const StarknetProvider = ({ children }: StarknetProviderProps) => {
  const provider = useMemo(() => {
    return jsonRpcProvider({
      rpc: () => ({
        nodeUrl: dojoConfig.rpcUrl,
      }),
    });
  }, []);

  const connector = useMemo(() => new ControllerConnector({
    chains: [{rpcUrl: dojoConfig.rpcUrl}],
    defaultChainId: constants.StarknetChainId.SN_SEPOLIA,
    colorMode: 'dark',
    theme: "zktt",
    policies: {
      contracts: {
        [CASHIER_CONTRACT_ADDRESS]: {
          methods: [
            {
              name: "deposit_erc20",
              entrypoint: "deposit_erc20",
              description: "Used to deposit chips into player account to use at tables."
            }
          ]
        },
        [ACTIONS_CONTRACT_ADDRESS]: {
          methods: [
            {
              name: "join_table",
              entrypoint: "join_table",
              description: "Used to join poker rooms."
            }
          ]
        }
      }
    },
  }), []);

  return (
    <StarknetConfig chains={[sepolia, mainnet]} provider={provider} connectors={[connector]}
    autoConnect>
      <ControllerProvider>
        <StarknetWalletProvider>
          <DojoWrapper>{children}</DojoWrapper>
        </StarknetWalletProvider>
      </ControllerProvider>
    </StarknetConfig>
  );
};

export default StarknetProvider;

// Separate component to use Starknet hooks after StarknetConfig is initialized
const StarknetWalletProvider = ({children}: { children: React.ReactNode }) => {
  const { address, username, status, connect, disconnect } = useController();
  const walletAccount = StarknetChainFactory.useWalletAccount("sepolia");

  walletAccount.address = address ?? "0x0";
  walletAccount.username = username ?? "N/A";
  walletAccount.status = status;
  walletAccount.connect = connect;
  walletAccount.disconnect = disconnect;

  const client = StarknetChainFactory.getChainClient('sepolia', walletAccount);
  return (
    <WalletContext.Provider value={{ wallet: walletAccount, client: client }}>
      {children}
    </WalletContext.Provider>
  );
};
