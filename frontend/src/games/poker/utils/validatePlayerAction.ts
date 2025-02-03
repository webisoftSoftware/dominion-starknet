import { PokerAction } from '@frontend/games/poker/enums';
import { type PlayerAction, type PokerRoomContext } from '@frontend/games/poker/types';

/**
 * This function checks if the given action can be performed. It returns a PlayerAction object if yes, false otherwise.
 *
 * The returned action may be different from the given one. For exemple, a bet higher that the player's balance
 * will result in an all-in action with the maximum possible amount.
 *
 * @param action
 * @param context
 */
export function validatePlayerAction(action: PlayerAction, context: PokerRoomContext) {
  // Validate player is indeed in game
  const player = context.players.find((player) => player.address === action.playerAddress);

  if (!player) {
    return false;
  }

  // If the action is a bet, validate the player balance is above zero
  if (
    (action.action === PokerAction.Raise ||
      action.action === PokerAction.Call ||
      action.action === PokerAction.AllIn) &&
    player.balance <= 0
  ) {
    // Player cannot bet with a balance of zero
    return false;
  }

  // If the action is a bet, but the player balance is not enough, or is the exact balance amount, change the action to an all in
  if (
    (action.action === PokerAction.Raise || action.action === PokerAction.Call) &&
    (player.balance < action.amount || player.balance === action.amount)
  ) {
    return {
      ...action,
      action: PokerAction.AllIn,
      amount: player.balance,
    };
  }

  // Action is OK
  return action;
}
