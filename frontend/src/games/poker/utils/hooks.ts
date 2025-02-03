import React from 'react';

import { makePokerClient, type PokerClient } from '@frontend/games/poker/client';
import type { PokerRoomClient } from '@frontend/games/poker/client/PokerRoomClient';
import type { ActorRoomState } from '@frontend/games/poker/pokerRoomStateMachine';
import type { PokerRoomContext, PokerRoomSelector } from '@frontend/games/poker/types';
import { useChainClient } from '@frontend/providers/ChainsProvider/utils';

export const PokerRoomCtx = React.createContext<
  [state: PokerRoomContext, actor: ActorRoomState, client: PokerRoomClient]
>([] as unknown as [PokerRoomContext, ActorRoomState, PokerRoomClient]);

/**
 * Returns the raw poker room context
 */
export function usePokerRoom() {
  return React.useContext(PokerRoomCtx);
}

/**
 * Returns the current state of the poker room
 */
export function usePokerRoomState() {
  const [, actor] = usePokerRoom();
  return actor.getSnapshot().value;
}

/**
 * Uses the given selector to extract a value from the poker room state/context
 * @param selector
 */
export function usePokerRoomSelector<S>(selector: PokerRoomSelector<S>): S {
  const [context, actor] = usePokerRoom();
  return selector(context, actor.getSnapshot().value);
}

/**
 * Return a poker client instance
 */
export const usePokerClient = (): PokerClient | null => {
  const client = useChainClient();

  return React.useMemo(() => (client ? makePokerClient(client) : null), [client]);
};
