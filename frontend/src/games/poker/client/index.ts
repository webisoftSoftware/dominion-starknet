import { Chains } from '@frontend/chains';
import { ChainException } from '@frontend/chains/ChainException';
import type { ChainClient, WalletAccount } from '@frontend/chains/types';
import type { PokerClient } from '@frontend/games/poker/client/PokerClient';
import type { PokerRoomClient } from '@frontend/games/poker/client/PokerRoomClient';

export * from './PokerClient';
export type * from './types';

export function makePokerClient(client: ChainClient): PokerClient {
  const pokerClient = Chains.getPokerClient(client);

  if (!pokerClient) {
    throw new ChainException(`Chain ${client.getChainId()} does not support Poker`);
  }

  return pokerClient;
}

export async function makePokerRoomClient(
  roomId: number,
  client: PokerClient,
  wallet: WalletAccount,
): Promise<PokerRoomClient> {
  const pokerClient = await Chains.getPokerRoomClient(roomId, client, wallet);

  if (!pokerClient) {
    throw new ChainException(`Chain ${client.getChainId()} does not support Poker`);
  }

  return pokerClient;
}
