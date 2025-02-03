import {
  CHAIN_TYPE,
  type ChainType,
  type ChainClient,
  type ChainDetails,
  type ChainFactory,
  type WalletAccount,
} from './types';
import type { PokerClient } from '@frontend/games/poker/client';
import { StarknetChainFactory } from '@frontend/chains/starknet/StarknetChainFactory';

const chainFactories: Record<ChainType, ChainFactory> = {
  [CHAIN_TYPE.STARKNET]: StarknetChainFactory,
};

export class Chains {
  public static listChains(): ChainDetails[] {
    return Object.entries(chainFactories).flatMap(([, factory]) =>
      factory.listChains().map((chain) => factory.getChainDetails(chain)),
    );
  }

  public static getChainRestEndoint(type: ChainType, chainId: string) {
    return chainFactories[type].getChainRestEndpoint(chainId);
  }

  public static getChainRpcEndoint(type: ChainType, chainId: string) {
    return chainFactories[type].getChainRpcEndpoint(chainId);
  }

  public static getClient(type: ChainType, chainId: string, account: WalletAccount) {
    return chainFactories[type].getChainClient(chainId, account);
  }

  // MARK: - Poker

  public static getPokerClient(client: ChainClient) {
    return chainFactories[client.getChainType()].getPokerClient(client);
  }

  public static getPokerRoomClient(roomId: number, pokerClient: PokerClient, wallet: WalletAccount) {
    return chainFactories[pokerClient.getChainType()].getPokerRoomClient(roomId, pokerClient, wallet);
  }
}
