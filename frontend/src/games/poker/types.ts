import { type SnapshotFrom } from 'xstate';

import type { Address } from '@frontend/chains/types';
import { PokerAction, PokerEventType, PokerState } from '@frontend/games/poker/enums';
import type { ActorRoomState } from '@frontend/games/poker/pokerRoomStateMachine';
import type {
  Card,
  CommunityRevealTokens,
  Deck,
  MaskedDeck,
  PlayerRevealTokens,
  RevealToken,
} from '@frontend/games/poker/resources/cards';
import type { ChatMessage } from '@frontend/games/poker/resources/messages';
import type { Player } from '@frontend/games/poker/resources/player';

/**
 * All the streets with includes a reveal of community cards at the beginning
 */
export type PokerStreetStateWithCommunityCards = PokerState.Flop | PokerState.Turn | PokerState.River;

/**
 * All four streets
 */
export type PokerStreetState = PokerState.PreFlop | PokerStreetStateWithCommunityCards;

/**
 * Used to split the pot between the winners, NOT IMPLEMENTED (YET? lol)
 */
export interface Pot {
  total: number;
  winningHandsString: Card[][];
  winners: string[];
}

/**
 * Used to represent a player action in a poker game
 */
export interface PlayerAction {
  playerAddress: string;
  roundId: number;
  street: PokerStreetState;

  action: PokerAction;
  amount: number;
}

export interface SignedPlayerAction extends PlayerAction {
  actionPubKey: string;
  signature: string;
}

export type EndGamePayload = Record<string, string>;

export type ShowDownDecision = { sender: string; decision: 'muck' | 'show' };

/**
 * The internal context of the poker room machine
 * Using context information outside of the machine should only be done through selector, and the `usePokerRoomState()` hook if within React.
 */
export interface PokerRoomContext {
  roomId: number;
  roundId: number;

  /**
   * True during the preparation phase, false otherwise.
   * All side-effects should be prevented while this flag is enabled.
   */
  isPreparing: boolean;

  /**
   * How many players this room can seat
   */
  seatsCount: number;

  /**
   * Address of the player on this computer, null if spectator
   */
  playerAddress: string | null;

  /**
   * Address of the contract used for this game
   */
  contractAddress: string;

  /**
   * Players currently in the game
   */
  players: Player[];

  /**
   * Players waiting to take part of the next game
   */
  waitingPlayers: Player[];

  /**
   * The players whose turn it is
   */
  activeSeatIndex: number | null;

  /**
   * History of all the actions taken by the players during this round
   */
  playerActions: SignedPlayerAction[];

  /**
   * History of all the actions taken by the players during the previous round
   */
  previousRoundPlayerActions: SignedPlayerAction[];

  /**
   * The deck, as provided by the contract, before it gets shuffled
   */
  initialDeck: MaskedDeck;
  /**
   * All the shuffled decks
   */
  shuffledDecks: Deck[];

  /**
   * The masked community cards to be revealed on the proper street.
   */
  communityCardsForReveal?: {
    [K in PokerStreetStateWithCommunityCards]: K extends PokerState.Flop ? [string, string, string] : [string];
  };

  /**
   * The Revealed community cards
   */
  communityCards: Card[];

  /**
   *
   */
  minimumTableEntryBalance: number;

  /**
   *
   */
  smallBlind: number;

  /**
   * The current street the game is in, this does not include pre-flop as its logic is different from the other streets
   */
  street: PokerStreetStateWithCommunityCards | null;

  /**
   * The pots holds the money currently betted on the table
   * There should be only a single plot at the beginning of the game,
   * that gets put to the side when a player goes all-in, in favor of a new one, repeating this step everytime player goes all in
   * When winning a game, a player can only receive the money in the pots they contributed to
   *
   * TODO: Not implemented yet
   */
  pots: Pot[];

  // Is this still usefull now that we have a state machine ?
  showdownActivePotIndex: number | null;

  /**
   * All the reveal tokes received from the players, they are to be used to reveal the current user hand
   */
  revealTokens: PlayerRevealTokens[];

  /**
   * The proof of hands as sent by the players. The list of tokens include all the reveal tokens necessary to view the player hand
   */
  proofOfHands: Record<Address, [RevealToken, RevealToken][]>;

  /**
   * All the reveal tokens received from the players, they are to be used to reveal the community cards
   */
  communityCardsRevealTokens: Record<PokerStreetStateWithCommunityCards, CommunityRevealTokens[]>;

  /**
   * What each player has decided during showdown
   */
  showdownDecisions: ShowDownDecision[];

  /**
   * Holds the final results of the game.
   * It currently stores the raw wasm attributes returned by the contract when ending the game
   */
  endGameAttributes: EndGamePayload | null;

  /**
   * The chat messages
   */
  chatMessages: ChatMessage[];

  jointPk: Uint8Array;
}

/**
 * All the event shapes that can be sent to the machine
 */
export type PokerEvent =
  | { type: PokerEventType.PlayerJoined; payload: Partial<PokerRoomContext> }
  | { type: PokerEventType.PlayerWaiting; payload: { players: Player[] } }
  | { type: PokerEventType.PlayerLeft; payload: { address: string } }
  | { type: PokerEventType.NewGameStarted }
  | { type: PokerEventType.RoomIsReady; payload: Partial<PokerRoomContext> }
  | {
      type: PokerEventType.RoomStateUpdated;
      payload: (context: PokerRoomContext) => Partial<PokerRoomContext>;
      label: string;
    }
  | { type: PokerEventType.OwnCardsRevealed; payload: { cards: [Card, Card] } }
  | { type: PokerEventType.PlayerPerformedAction; payload: SignedPlayerAction }
  | { type: PokerEventType.NextPlayerTurn; payload: { nextSeatIndex: number } }
  | { type: PokerEventType.EndOfStreet }
  | {
      type: PokerEventType.CommunityCardsRevealed;
      payload: { street: PokerStreetStateWithCommunityCards; cards: Card[] };
    }
  | { type: PokerEventType.EndOfGame }
  | { type: PokerEventType.FinalEvalReceived; payload: EndGamePayload }
  | { type: PokerEventType.StartNewRound; payload: Partial<PokerRoomContext> }
  | { type: PokerEventType.UserIsSpectator }
  | { type: PokerEventType.ChatReceived; payload: ChatMessage[] }
  | { type: PokerEventType.PreparingDone };

/**
 * Type for the Poker room selectors
 */
export type PokerRoomSelector<S> = (context: PokerRoomContext, state: SnapshotFrom<ActorRoomState>['value']) => S;
