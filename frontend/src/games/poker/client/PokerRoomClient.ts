import type { Observable } from 'rxjs';
import type { ActorRef, Snapshot } from 'xstate';

import type { ChatMessage } from '@frontend/games/poker/resources/messages';
import type { PlayerAction, PokerEvent, PokerRoomContext } from '../types';

/**
 * This class is the link between the state machine and the chain implementation.
 *
 * It is responsible for:
 * - Fetching the current state of the room
 * - Sending actions to the chain
 * - Listening to events from the chain
 * - Handling chat messages (if applicable)
 *
 * If a method returns a PokerEvent, it will be broadcasted directly to the machine.
 * Some
 */
export interface PokerRoomClient {
  /**
   * Returns the ID of the chain
   */
  getChainId(): string;

  /**
   * Returns the data for the room, type is declared as partial to give some flexibility to each chain implementation
   */
  getRoom(): Promise<Partial<PokerRoomContext>>;

  /**
   * Let the client gracefully terminate any resources it might have opened
   */
  terminate(): Promise<void>;

  /**
   * Tell if the current room has a chat
   */
  hasChat(): boolean;

  /**
   * Send a chat message to the room
   * @param message
   */
  sendChatMessage(message: ChatMessage): Promise<void>;

  /**
   * Provide the current context of the room, to be used with the internal state machine. as well as the curretn state of the game
   *
   * If the chain cannot provide the actual state of the game, a list of events can be provided to bring the machine up the current state
   * Passed events will be given to the state machine to bring the room to the current state, in a closed machine with side-effects disabled.
   * Once fast-forwarding is done, the up-to-date state will be applied to a fully-fledged state machine.
   */
  getInitRoomData(): Promise<{
    context: PokerRoomContext;
    events: PokerEvent[];
  }>;

  /**
   * Returns an `Observable` that emits `PokerEvent` objects for the room in response from event received from the chain (or other places)
   */
  getExternalEventsObservable(machine: ActorRef<Snapshot<PokerRoomContext>, PokerEvent>): Observable<PokerEvent>;

  /**
   * Join the provided user(wallet) to the specified room
   */
  joinRoom(seatIndex: number, buyInAmount: number): Promise<boolean>;

  /**
   * Make the provided user leave the room
   */
  leaveRoom(): Promise<boolean>;

  /**
   * Called by the state machine everytime when a new round starts, and everytime an event is received while in the preparing state
   * An event of type `PokerEventType.RoomIsReady` must be raised once the user can see their own cards
   * @param machine
   */
  prepareRoom(machine: PokerRoomContext): Promise<PokerEvent | null>;

  /**
   * Called by the state machine when it is time for the player to look at his own cards, and everytime the room states updates while waiting for the cards to be revealed
   * An event of type `PokerEventType.OwnCardRevealed` must be raised once the user can see their own cards, or an event of type `PokerEventType.UserIsSpectator` if the user is a spectator
   * @param context
   */
  revealOwnHand(context: PokerRoomContext): Promise<PokerEvent | null>;

  /**
   * Called when the player performs a game action (bet, raise, call, etc.)
   * This method is not called by the state machine in response to an event, but directly by the user interface in a response to a user action.
   * The machine state has not been updated at this point from the action, and will only do so upon receiving an actual event with the action
   * @param action
   */
  sendGameAction(action: PlayerAction): Promise<PokerEvent | null>;

  /**
   * Called by the state machine when it is time for the community cards to be revealed, and everytime the room states updates while waiting for the cards to be revealed
   * @param context
   */
  revealCommunityCards(context: PokerRoomContext): Promise<PokerEvent | null>;

  /**
   * Called by the state machine when it is time for the player to reveal its hand to the other players, and everytime the room states updates while waiting for the cards to be revealed
   * After all hands have been revealed, an event of type `EndOfRound` must be raised by the client to give the machine the results of the game, and start a timer until reload for the next round
   * @param context
   */
  revealHand(context: PokerRoomContext): Promise<PokerEvent | null>;
}
