import { type Address, CHAIN_TYPE, type ChainClient } from '@frontend/chains/types';
import { StarknetChain } from '@frontend/chains/starknet/types';
import { Account, AccountInterface, BigNumberish, ByteArray } from 'starknet';
import { StructCard } from '@frontend/dojo/models';
import { Result } from 'starknet';
import { InvokeFunctionResponse } from 'starknet';

export enum NetworkType {
  Sepolia,
  Mainnet
}

export interface StarknetClientParameters {
  chainIcon: string,
  chainNetwork: NetworkType,
  rpcEndpoint: string,
  contracts:  {
    cashier_system: {
      depositErc20: (snAccount: Account | AccountInterface, amount: bigint) => Promise<InvokeFunctionResponse | undefined>,
      cashoutErc20: (snAccount: Account | AccountInterface, amount: bigint) => Promise<InvokeFunctionResponse | undefined>,
      claimFees: (snAccount: Account | AccountInterface) => Promise<InvokeFunctionResponse | undefined>,
      transferChips: (snAccount: Account | AccountInterface, to: string, amount: bigint) => Promise<InvokeFunctionResponse | undefined>,
      setTreasuryAddress: (snAccount: Account | AccountInterface, treasuryAddress: Address) => Promise<InvokeFunctionResponse | undefined>,
      setVaultAddress: (snAccount: Account | AccountInterface, vaultAddress: Address) => Promise<InvokeFunctionResponse | undefined>,
      setPaymasterAddress: (snAccount: Account | AccountInterface, paymasterAddress: Address) => Promise<InvokeFunctionResponse | undefined>,
      getTreasuryAddress: (snAccount: Account | AccountInterface) => Promise<Result | undefined>,
      getVaultAddress: (snAccount: Account | AccountInterface) => Promise<Result | undefined>,
      getPaymasterAddress: (snAccount: Account | AccountInterface) => Promise<Result | undefined>,
    },
    table_management_system: {
      postEncryptDeck: (snAccount: Account | AccountInterface, tableId: BigNumberish, encryptedDeck: Array<StructCard>) => Promise<InvokeFunctionResponse | undefined>,
      postDecryptedCommunityCards: (snAccount: Account | AccountInterface, tableId: BigNumberish, cards: Array<StructCard>) => Promise<InvokeFunctionResponse | undefined>,
      skipTurn: (snAccount: Account | AccountInterface, tableId: BigNumberish, player: string) => Promise<InvokeFunctionResponse | undefined>,
      kickPlayer: (snAccount: Account | AccountInterface, tableId: BigNumberish, player: string) => Promise<InvokeFunctionResponse | undefined>,
      createTable: (snAccount: Account | AccountInterface, smallBlind: BigNumberish, bigBlind: BigNumberish, minBuyIn: BigNumberish, maxBuyIn: BigNumberish, rakeFee: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      shutdownTable: (snAccount: Account | AccountInterface, tableId: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      changeTableManager: (snAccount: Account | AccountInterface, newTableManager: string) => Promise<InvokeFunctionResponse | undefined>,
      getTableManager: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTableLength: (tableId: BigNumberish) => Promise<Result | undefined>,
      getGameState: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTablePlayers: (tableId: BigNumberish) => Promise<Result | undefined>,
      getCurrentTurn: (tableId: BigNumberish) => Promise<Result | undefined>,
      getCurrentSidepots: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTableCommunityCards: (tableId: BigNumberish) => Promise<Result | undefined>,
      isDeckEncrypted: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTableLastPlayedTs: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTableMinBuyIn: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTableMaxBuyIn: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTableRakeFee: (tableId: BigNumberish) => Promise<Result | undefined>,
      getTableLastRaiser: (tableId: BigNumberish) => Promise<Result | undefined>,
    },
    actions_system: {
      bet: (snAccount: Account | AccountInterface, tableId: BigNumberish, chipsAmount: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      fold: (snAccount: Account | AccountInterface, tableId: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      postAuthHash: (snAccount: Account | AccountInterface, tableId: BigNumberish, authHash: ByteArray) => Promise<InvokeFunctionResponse | undefined>,
      postCommitHash: (snAccount: Account | AccountInterface, tableId: BigNumberish, commitmentHash: Array<BigNumberish>) => Promise<InvokeFunctionResponse | undefined>,
      topUpTableChips: (snAccount: Account | AccountInterface, tableId: BigNumberish, chipsAmount: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      setReady: (snAccount: Account | AccountInterface, tableId: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      joinTable: (snAccount: Account | AccountInterface, tableId: BigNumberish, chipsAmount: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      leaveTable: (snAccount: Account | AccountInterface, tableId: BigNumberish) => Promise<InvokeFunctionResponse | undefined>,
      revealHandToAll: (snAccount: Account | AccountInterface, tableId: BigNumberish, decryptedHand: Array<StructCard>, request: ByteArray) => Promise<InvokeFunctionResponse | undefined>,
      getPlayerState: (tableId: BigNumberish, player: string) => Promise<Result | undefined>,
      getPlayerBet: (tableId: BigNumberish, player: string) => Promise<Result | undefined>,
      getPlayerPosition: (tableId: BigNumberish, player: string) => Promise<Result | undefined>,
      getPlayerTableChips: (tableId: BigNumberish, player: string) => Promise<Result | undefined>,
      hasPlayerRevealed: (tableId: BigNumberish, player: string) => Promise<Result | undefined>,
    },
  },
  userAccount: AccountInterface
}

export class StarknetClient implements ChainClient {
  protected static readonly CHIP_TO_ETH = 0.001 / 1000; // 1000 Chips per 0.001 ETH

  public readonly chainNetwork: NetworkType;
  public readonly chainIcon: string;
  /// RPC endpoint to interact with the chain
  public readonly rpcEndpoint: string;
  public readonly contracts: object;

  constructor(params: StarknetClientParameters) {
    this.chainIcon = params.chainIcon;
    this.chainNetwork = params.chainNetwork;
    this.rpcEndpoint = params.rpcEndpoint;
    this.contracts = params.contracts;
  }

  public getChainType() {
    return CHAIN_TYPE.STARKNET;
  }

  public getChainId() {
    return StarknetChain;
  }

  public getTableManagerAddress(): Address {
    return 'TODO';
  }

  public async getBalance(address: Address): Promise<number> {
    // TODO: Implement this
    return 0;
  }
}
