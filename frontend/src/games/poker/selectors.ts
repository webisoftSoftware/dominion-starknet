import Big from 'big.js';

import { PokerAction, PokerState } from '@frontend/games/poker/enums';
import {
  type PlayerAction,
  type PokerRoomContext,
  type PokerRoomSelector,
  type PokerStreetState,
} from '@frontend/games/poker/types';
import type { Card } from '@frontend/games/poker/resources/cards';
import type { ChatMessage } from '@frontend/games/poker/resources/messages';
import type { Player } from '@frontend/games/poker/resources/player';

/**
 * Returns the whole context
 * @param context
 */
export const selectRoom: PokerRoomSelector<PokerRoomContext> = (context) => context;

/**
 * Returns only the ID of the current room
 * @param context
 */
export const selectRoomId: PokerRoomSelector<number> = (context) => context.roomId;

/**
 * Return the current round ID for the room
 * @param context
 */
export const selectRoundId: PokerRoomSelector<number> = (context) => context.roundId;

export const selectStreet: PokerRoomSelector<PokerStreetState | null> = (context, state) => {
  if (typeof state === 'string') {
    return null;
  }

  if (PokerState.PreFlop in state) {
    return PokerState.PreFlop;
  }

  if (PokerState.Street in state) {
    return context.street;
  }

  return null;
};

/**
 * Returns the required minimum balance to enter the table
 * @param context
 */
export const selectMinimumEntryBalance: PokerRoomSelector<number> = (context) => context.minimumTableEntryBalance;

/**
 * Returns the small blind amount
 * @param context
 */
export const selectSmallBlind: PokerRoomSelector<number> = (context) => context.smallBlind;

/**
 * Returns all the players in the room. This does not include waiting players
 * @param context
 */
export const selectPlayers: PokerRoomSelector<Player[]> = (context) => {
  return context.players;
};

/**
 * Returns all the players waiting to join the game. These players have already koined the room, but are not part of the current game
 * @param context
 */
export const selectWaitingPlayers: PokerRoomSelector<Player[]> = (context) => {
  return context.waitingPlayers;
};

/**
 * Returns the Player object matching the current user, wether from the active or waiting players lists
 * @param context
 */
export const selectPlayer: PokerRoomSelector<Player | null> = (context) => {
  return (
    context.players.find((p) => p.address === context.playerAddress) ??
    context.waitingPlayers.find((p) => p.address === context.playerAddress) ??
    null
  );
};

/**
 * Returns the players whose the one currently playing
 * @param context
 */
export const selectActivePlayer: PokerRoomSelector<Player | undefined> = (context) => {
  return context.players.find((player) => player.seatIndex === context.activeSeatIndex);
};

/**
 * Tell if the game has started, this means the game is either in progress or preparing to start
 * @param _
 * @param state
 */
export const selectIsGameStarted: PokerRoomSelector<boolean> = (_, state) => {
  return typeof state === 'object';
};

export const selectPlayerActions: PokerRoomSelector<PlayerAction[]> = (context) => {
  return context.playerActions;
};

export const selectPreviousRoundPlayerActions: PokerRoomSelector<PlayerAction[]> = (context) => {
  return context.previousRoundPlayerActions;
};

/**
 * Select all the community cards
 * @param context
 */
export const selectCommunityCards: PokerRoomSelector<Card[]> = (context) => {
  return context.communityCards;
};

export const selectHighestBet: PokerRoomSelector<Big> = (context) => {
  return context.players.map((player) => new Big(player.totalBetInRound)).reduce((a, b) => (a > b ? a : b), new Big(0));
};

/**
 * List all the action the current active player can perform.
 * Action amounts are not calculated here, only the possible actions
 * @param context
 * @param state
 */
export const selectAvailablePlayerActions: PokerRoomSelector<PokerAction[]> = (context, state) => {
  // get the player for the current user
  const player = context.players.find((player) => player.address === context.playerAddress);

  if (!player) {
    // User is spectator
    return [];
  }

  const playerBalance = new Big(player.balance).sub(new Big(player.totalBetInRound));

  // Are we in a round ?
  const street = selectStreet(context, state);

  if (!street) {
    return [];
  }

  const actions: PokerAction[] = [];

  const streetActions = context.playerActions.filter(
    (action) => action.roundId === context.roundId && action.street === street,
  );

  // const lastAction = streetActions[streetActions.length - 1];
  const lastNonFoldAction = streetActions.findLast((action) => action.action !== PokerAction.Fold);

  const highestBet = selectHighestBet(context, state);
  const playerCallAmount = highestBet.sub(new Big(player.totalBetInRound));

  // A player can check only if nothing else than checks have been made before for the street
  // We do not check for the pre-flop blinds as these are played automatically
  if (!streetActions.some((action) => action.action !== PokerAction.Check)) {
    // Actions is either empty or only contains checks
    actions.push(PokerAction.Check);
  } else if (lastNonFoldAction && playerBalance >= playerCallAmount) {
    // Can the player call ? (match the previous amount bet)
    actions.push(PokerAction.Call);
  }

  if (playerBalance > playerCallAmount) {
    actions.push(PokerAction.Raise);
  }

  actions.push(PokerAction.Fold);
  actions.push(PokerAction.AllIn);

  return actions;
};

export const selectIsWaitingForPlayerAction: PokerRoomSelector<boolean> = (_, state) => {
  return typeof state === 'object' && Object.values(state).includes(PokerState.StreetPendingAction);
};

export const selectMinimumRaise: PokerRoomSelector<Big> = (context, state) => {
  const highestBet = selectHighestBet(context, state);
  return highestBet.mul(2);
};

export const selectMaximumBetAmount: PokerRoomSelector<Big> = (context, state) => {
  const activePlayer = selectActivePlayer(context, state);

  if (!activePlayer) {
    return new Big(0);
  }

  const balances = context.players.map((player) => player.balance).sort((a, b) => b - a);

  return balances[0] === activePlayer.balance
    ? new Big(balances[1]!)
    : new Big(activePlayer.balance).sub(new Big(activePlayer.totalBetInRound));
};

export const selectIsAllInOnTable: PokerRoomSelector<boolean> = (context) => {
  return context.players.some((player) => player.roundAction === PokerAction.AllIn);
};

/**
 * Tell if the game is currently in its showdown state
 * @param context
 * @param state
 */
export const selectIsShowdown: PokerRoomSelector<boolean> = (context, state) => {
  return typeof state === 'object' && PokerState.Showdown in state;
};

/**
 * Select which pot is the active one during showdown
 * @param context
 */
export const selectShowdownActivePot: PokerRoomSelector<PokerRoomContext['pots'][0] | null> = (context) => {
  return context.pots[context.showdownActivePotIndex ?? 0] ?? null;
};

/**
 * Select the grand total of the table for the game
 * @param context
 */
export const selectGrandTotal: PokerRoomSelector<number> = (context) => {
  const potsTotal = context.pots.reduce((total, pot) => total.add(new Big(pot.total)), new Big(0));
  const playersRoundBets = context.players.reduce((total, player) => {
    return total.add(Big(player.totalBetInRound ?? 0));
  }, new Big(0));
  return potsTotal.add(playersRoundBets).toNumber();
};

/**
 * Select all the chat messages in the room
 * @param context
 */
export const selectChatMessages: PokerRoomSelector<ChatMessage[]> = (context) => {
  return context.chatMessages;
};

/**
 * Returns the list of all players in the game, in order of play, starting by the small blind
 * @param context
 */
export const selectPlayersInOrder: PokerRoomSelector<Player[]> = (context) => {
  const orderedPlayers = context.players.sort((a, b) => Math.sign(a.seatIndex! - b.seatIndex!));
  const smallBlindOffset = orderedPlayers.findIndex((player) => player.isSmallBlind);

  return orderedPlayers.slice(smallBlindOffset).concat(orderedPlayers.slice(0, smallBlindOffset));
};

export const selectEndGameAttributes: PokerRoomSelector<PokerRoomContext['endGameAttributes']> = (context) => {
  return context.endGameAttributes;
};
