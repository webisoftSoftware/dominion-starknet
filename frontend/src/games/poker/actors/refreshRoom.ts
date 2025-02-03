import { fromPromise } from 'xstate';

import type { PokerRoomClient } from '@frontend/games/poker/client/PokerRoomClient';
import { type PokerEvent, type PokerRoomContext } from '@frontend/games/poker/types';

/**
 * This action pulls and return an up-to-date version of the room from the contract
 * @param pokerClient
 */
export const refreshRoom = ({ pokerRoomClient }: { pokerRoomClient: PokerRoomClient }) =>
  fromPromise<Partial<PokerRoomContext>, PokerRoomContext, PokerEvent>(async () => {
    console.log('[Poker:refreshRoom] refreshing room');

    return pokerRoomClient.getRoom();
  });
