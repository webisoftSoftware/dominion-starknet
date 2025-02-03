import Big from 'big.js';
import { enqueueActions } from 'xstate';

import { PokerAction, PokerEventType, PokerState } from '@frontend/games/poker/enums';
import { type PokerEvent, type PokerRoomContext } from '@frontend/games/poker/types';
import { Player } from '@frontend/games/poker/resources/player';

/**
 * Executed following a player poker. Validate the action is not a duplicate of the previous one,
 * then update player bets, check if the round is over, and if not, check the next player to play.
 */
export const handlePlayerAction = () =>
  enqueueActions<PokerRoomContext, PokerEvent, void>(({ context, enqueue, event }) => {
    console.log(event);

    if (event.type !== PokerEventType.PlayerPerformedAction) {
      // Wrong event type
      return;
    }

    // The action to check is already in the context
    // Check the action is different from the previous one
    // This is to prevent any action being handled twice
    // it should not happen, but it doesn't hurt to check
    const { playerAddress, action, amount } = context.playerActions.at(-1)!;
    const previousAction = context.playerActions.at(-2);

    if (previousAction) {
      if (
        previousAction.playerAddress === event.payload.playerAddress &&
        previousAction.roundId === event.payload.roundId &&
        previousAction.street === event.payload.street
      ) {
        // Same player, same round, same step, ignore
        console.log('[Poker] Same player, same round, same step, ignore');
        const actions = [...context.playerActions];
        actions.pop();
        enqueue.assign({ playerActions: actions });
        enqueue.raise({
          type: PokerEventType.NextPlayerTurn,
          payload: { nextSeatIndex: context.activeSeatIndex! },
        });
        return;
      }
    }

    if (context.players.find((p) => p.address === playerAddress) === undefined) {
      // Invalid action, ignore
      return;
    }

    const player = { ...context.players.find((p) => p.address === playerAddress)! };

    const amountBig = new Big(amount);

    if (
      action === PokerAction.SmallBlind ||
      action === PokerAction.BigBlind ||
      action === PokerAction.Raise ||
      action === PokerAction.Call ||
      action === PokerAction.AllIn
    ) {
      player.betInStreet = new Big(player.betInStreet).add(amountBig).toNumber();
      player.totalBetInRound = new Big(player.totalBetInRound).add(amountBig).toNumber();
    }

    player.roundAction = action;

    // Save updated player to the context; We keep a copy of the updated player array to use after because enqueued actions are only executed at the end
    const players = context.players.map((p) => (p.address === playerAddress ? player : p));
    enqueue.assign({ players: players });

    // Compute next active player, or end round, or end game
    // Check if all players minus one have folded
    if (players.filter((p) => p.roundAction === PokerAction.Fold && p.isActive).length === players.length - 1) {
      // Only one player hasn't folded, he wins the round, finish the game
      console.debug('[Poker:handlePlayerAction] End of game: only one player not folded');
      enqueue.raise({ type: PokerEventType.EndOfGame });
      return;
    }

    // Check if all non-folded, non-all-in players have the same bet
    const runningBets = players
      .filter((p) => p.roundAction !== PokerAction.Fold && p.roundAction !== PokerAction.AllIn)
      .map((p) => new Big(p.totalBetInRound));
    const allBetsAreEqual = runningBets.length > 0 && runningBets.every((b) => b.eq(runningBets[0]!));

    // If all players have played, and all running bets are equal, we can end the street
    if (allBetsAreEqual && players.filter((p) => p.roundAction === null).length === 0) {
      console.debug('[Poker:handlePlayerAction] End of street: All bets are equal');
      enqueue.raise({ type: PokerEventType.EndOfStreet });
      return;
    }

    // Loop across players to find the next one
    // Ignore the current player, of course, the players that have folded, are all in, or are not active
    let nextPlayer: Player | null = null;

    for (let seatIndex = 1; seatIndex < players.length; seatIndex++) {
      const possibleNextPlayer = players[(seatIndex + context.activeSeatIndex!) % players.length];

      // If the player does not exist or is the player that just played, skip it
      if (!possibleNextPlayer || possibleNextPlayer.address === playerAddress || !possibleNextPlayer.isActive) {
        continue;
      }

      // Ignore players who cannot play anymore
      if (possibleNextPlayer.roundAction === PokerAction.Fold || possibleNextPlayer.roundAction === PokerAction.AllIn) {
        continue;
      }

      // possibleNextPlayer is the next player
      nextPlayer = possibleNextPlayer;
      break;
    }

    // Did we find a next player ?
    if (!nextPlayer) {
      // No next player, end of the round
      console.debug('[Poker:handlePlayerAction] End of street');
      enqueue.raise({
        type: context.street === PokerState.River ? PokerEventType.EndOfGame : PokerEventType.EndOfStreet,
      });
      return;
    }

    console.debug('[Poker:handlePlayerAction] Moving to player on seat index', nextPlayer.seatIndex!);
    enqueue.raise({
      type: PokerEventType.NextPlayerTurn,
      payload: { nextSeatIndex: nextPlayer.seatIndex! },
    });
    return;
  });
