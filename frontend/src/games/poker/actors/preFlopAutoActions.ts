import { toast } from 'react-hot-toast';
import { Observable } from 'rxjs';
import { fromEventObservable } from 'xstate';
import type { PokerRoomClient } from '@frontend/games/poker/client/PokerRoomClient';
import { PokerAction, PokerState } from '@frontend/games/poker/enums';
import { type PlayerAction, type PokerEvent, type PokerRoomContext } from '@frontend/games/poker/types';
import { validatePlayerAction } from '@frontend/games/poker/utils/validatePlayerAction';

/**
 * This action is used to automatically perform the small blind and big blind actions on pre-flop
 * @param pokerRoomClient
 */
export const preFlopAutoActions = (pokerRoomClient: PokerRoomClient) =>
  fromEventObservable<PokerEvent, PokerRoomContext, PokerEvent>(({ input: state }) => {
    return new Observable(() => {
      (async () => {
        console.log('[Poker:preFlopAutoActions] Performing pre-flop auto actions');

        const currentPlayer = state.players.find((p) => p.seatIndex === state.activeSeatIndex);

        if (!currentPlayer || currentPlayer.address !== state.playerAddress) {
          // Not our turn
          console.log('[Poker:preFlopAutoActions] Not our turn');
          return;
        }

        // Its our turn, did we already play, and are we the small bling/big blind ?
        if (currentPlayer.roundAction !== null) {
          // Player has already played this round, do nothing
          console.log('[Poker:preFlopAutoActions] Already played this round, no auto-action to perform');
          return;
        }

        if (!currentPlayer.isSmallBlind && !currentPlayer.isBigBlind) {
          // Player is not small blind or big blind, do nothing
          console.log('[Poker:preFlopAutoActions] No auto action to perform');
          return;
        }

        // Build our action
        const action: PlayerAction = {
          playerAddress: currentPlayer!.address,
          roundId: state.roundId,
          street: PokerState.PreFlop,
          action: currentPlayer.isBigBlind ? PokerAction.BigBlind : PokerAction.SmallBlind,
          amount: currentPlayer.isBigBlind ? state.smallBlind * 2 : state.smallBlind,
        };

        // We need to validate the action can be performed and is valid
        const validatedAction = validatePlayerAction(action, state);

        if (!validatedAction) {
          // The action is not valid, do nothing
          toast.error('Action cannot be performed');
          console.error('[Poker:preFlopAutoActions] Action cannot be performed', action);
          return;
        }

        // Action is valid, broadcast it to the room
        setTimeout(() => {
          console.log(`[Poker:preFlopAutoActions] Performing auto action ${action.action}`);
          void pokerRoomClient.sendGameAction(action);
        }, 1_500);
      })();
    });
  });
