import type { PokerClient } from '@frontend//games/poker/client/PokerClient';
import type { PokerRoomClient } from '@frontend//games/poker/client/PokerRoomClient';

export type Address = string;

type EnumType<T> = T[keyof T];

export const CHAIN_TYPE = {
  STARKNET: 'starknet',
} as const;
export type ChainType = EnumType<typeof CHAIN_TYPE>;

export interface ChainDetails {
  type: ChainType;
  id: string;
  name: string;
  icon: string;
  is_testnet: boolean;
}

export const WALLET_STATUS = {
  DISCONNECTED: 'disconnected',
  CONNECTED: 'connected',
  CONNECTING: 'connecting',
  ERROR: 'error',
} as const;
export type WalletStatus = EnumType<typeof WALLET_STATUS>;

export interface WalletAccount {
  type: ChainType;
  chain: string;
  address: Address | null;
  username: string | null;
  status: WalletStatus;
  //balance: number;

  getBalance: () => Promise<number>;

  connect: () => void;
  disconnect: () => void;

  currencySymbol: string;
  currencyDecimals: number;

  walletChainImpl: any;
  walletChainInfo: any;
}

export interface ChainClient {
  /**
   * Gives the chain type
   */
  getChainType: () => ChainType;

  /**
   * Gives the chain id
   */
  getChainId: () => string;

  /**
   * Retrieve the balance of the main token for the given address.
   * @param address
   */
  getBalance: (address: Address) => Promise<number>;
}

/**
 * Collect normalized methods for interacting with the chains.
 */
export interface ChainFactory {
  /**
   * List the ids of all the chains explicitely supported by the platform
   */
  listChains: () => string[];

  /**
   * Returns the details of the specified chain
   * @param chain
   */
  getChainDetails: (chain: string) => ChainDetails;

  /**
   * React Hook to fetch the current wallet. This is a hook and not a regular function
   * so it can subscribe to events, like if the user changes the wallet on its end and not through the UI.
   * @param chain
   */
  useWalletAccount: (chain: string) => WalletAccount;

  /**
   * Gives the HTTP endpoint URL of the specified chain
   */
  getChainRestEndpoint: (chain: string) => string;

  /**
   * Gives the Rpc endpoint URL of the specified chain
   */
  getChainRpcEndpoint: (chain: string) => string;

  /**
   * Returns the chain client for the given chain and account. This is used to perform queries and requests on the blockchain
   * @param chain
   * @param account
   */
  getChainClient: (chain: string, account: WalletAccount) => ChainClient;

  // MARK: - Poker

  /**
   * Returns the poker client for the given chain
   * @param client: Existing chain client
   */
  getPokerClient: (client: ChainClient) => PokerClient | null;

  /**
   * Returns the poker client for the given chain
   * @param client: Existing chain client
   */
  getPokerRoomClient: (roomId: number, client: PokerClient, wallet: WalletAccount) => Promise<PokerRoomClient | null>;
}
