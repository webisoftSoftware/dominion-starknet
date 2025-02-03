import { PokerState } from '../enums';
import type { PokerRoomContext } from '../types';

export function getCleanPokerRoomContext(): Omit<
  PokerRoomContext,
  'roomId' | 'roundId' | 'seatsCount' | 'playerAddress' | 'contractAddress'
> {
  return {
    isPreparing: false,
    playerActions: [],
    previousRoundPlayerActions: [],
    activeSeatIndex: null,
    shuffledDecks: [],
    street: null,
    players: [],
    waitingPlayers: [],
    initialDeck: [],
    communityCards: [],
    communityCardsRevealTokens: {
      [PokerState.Flop]: [],
      [PokerState.Turn]: [],
      [PokerState.River]: [],
    },
    revealTokens: [],
    pots: [],
    showdownActivePotIndex: null,
    showdownDecisions: [],
    proofOfHands: {},
    endGameAttributes: null,
    minimumTableEntryBalance: 0,
    smallBlind: 0.1,
    chatMessages: [],
    jointPk: Uint8Array.from([]),
  };
}

export function resetContext(currentContext: PokerRoomContext, freshRoom: Partial<PokerRoomContext>): PokerRoomContext {
  return {
    roomId: currentContext.roomId,
    roundId: freshRoom.roundId ?? currentContext.roundId,
    seatsCount: freshRoom.seatsCount ?? currentContext.seatsCount,

    ...getCleanPokerRoomContext(),
    ...freshRoom,

    // Carry over some properties from one round to the next
    playerAddress: currentContext.playerAddress,
    contractAddress: currentContext.contractAddress,
    chatMessages: currentContext.chatMessages,

    // Keep the player action of the last round for reference
    previousRoundPlayerActions: currentContext.playerActions,
  };
}
