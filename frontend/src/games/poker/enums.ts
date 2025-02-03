/**
 * All the actions a player can make in a Texas Hold'em game
 */
export enum PokerAction {
  SmallBlind = 'small-blind',
  BigBlind = 'big-blind',
  Call = 'call',
  Check = 'check',
  Fold = 'fold',
  Raise = 'raise',
  AllIn = 'all-in',
}

/**
 * All the event types that can be sent to the poker room machine
 */
export enum PokerEventType {
  /**
   * Raised when a player joins the gams as a player
   */
  PlayerJoined = 'PLAYER_JOINED',

  /**
   * Raised when a player joins as a waiting player, to play on the next round
   */
  PlayerWaiting = 'WAITING_PLAYER_JOINED',

  /**
   * Raised everytime a player lefts
   */
  PlayerLeft = 'PLAYER_LEFT',

  /**
   * Raised when a new round starts
   */
  NewGameStarted = 'NEW_GAME_STARTED',

  /**
   * Raised when the room is ready to start the game
   */
  RoomIsReady = 'ROOM_IS_READY',

  /**
   * Raised when the state/context of the room has changed
   */
  RoomStateUpdated = 'ROOM_STATE_UPDATE',

  /**
   * Raised everytime a reveal token is obtained, ever from the current player of from a remote one
   */
  RevealToken = 'REVEAL_TOKENS_RECEIVED',

  /**
   * Raised when the current player cards have been revealed
   */
  OwnCardsRevealed = 'OWN_CARDS_REVEALED',

  /**
   * Raised everytime a player performs an game action (call/check/bet/etc.)
   */
  PlayerPerformedAction = 'PLAYER_PERFORMED_ACTION',

  /**
   * Raised when the turns (pre-flop/flop/etc.) ends and the next one should start
   */
  NextPlayerTurn = 'NEXT_PLAYER_TURN',

  /**
   * Raised when the street (pre-flop/flop/etc.) ends and the next one should start. Should not be raised when River ends
   */
  EndOfStreet = 'END_OF_STREET',

  /**
   * Raised when community cards reveal tokens are received
   */
  CommunityRevealTokens = 'COMMUNITY_REVEAL_TOKENS',

  /**
   * Raised when some community cards have been revealed
   */
  CommunityCardsRevealed = 'COMMUNITY_CARDS_REVEALED',

  /**
   * Raised when the game is finished and prizes should be distributed. If showdown, this is raised after
   */
  EndOfGame = 'END_OF_GAME',

  /**
   * Raised when the contract has emited an `end_round` event
   */
  FinalEvalReceived = 'FINAL_EVAL_RECEIVED',

  /**
   * Raised when fresh room data has been fetched and a new game can be started
   */
  StartNewRound = 'START_NEW_ROUND',

  /**
   * This event is used to skip steps that are only required for a playing user
   */
  UserIsSpectator = 'USER_IS_SPECTATOR',

  /**
   * Raised when a chat message is received
   */
  ChatReceived = 'CHAT_RECEIVED',

  /**
   * Preparing the room is done
   */
  PreparingDone = 'PREPARING_DONE',
}

/**
 * All the states the poker machine can be in
 */
export enum PokerState {
  /**
   * 1. Game has not started, we are still waiting for players to join
   */
  Idle = 'idle',

  /**
   * 2. Players are ready, the room is being prepared, this includes shuffling the cards, distributing them, etc.
   */
  PreparingRoom = 'preparingRoom',

  /**
   * 3. All reveal tokens have been received, we reveal our own cards
   */
  RevealingOwnCards = 'revealingOwnCards',

  /**
   * 4. All players have revealed their own cards, waiting for the game to start
   */
  Ready = 'ready',

  /**
   * 5. Game is in progress, first street
   */
  PreFlop = 'preflop',

  /**
   * 6. Game is in progress, second, third and fourth
   */
  Street = 'street',

  /**
   * 7. Game is in progress, second street
   */
  Flop = 'flop',

  /**
   * 8. Game is in progress, third street
   */
  Turn = 'turn',

  /**
   * 9. Game is in progress, fourth and final street
   */
  River = 'river',

  /**
   * 6-7-8-9. Street substate, preparing the street
   */
  PreparingStreet = 'preparingStreet',

  /**
   * 6-7-8-9. Street substate, final preparations before players can actually start playing
   */
  StreetStart = 'streetStart',

  /**
   * 6-7-8-9. Street substate, waiting for a player to perform an action
   */
  StreetPendingAction = 'pendingPlayerAction',

  /**
   * 6-7-8-9. Street substate, processing the latest player action
   */
  StreetProcessingAction = 'processingPlayerAction',

  /**
   * 6-7-8-9. Street substate, Finalizing the street
   */
  StreetDone = 'streetDone',

  /**
   * 10. Game is done, all cards have been revealed
   */
  Showdown = 'showdown',

  /**
   * 12. Game is finished
   */
  EndRound = 'endRound',

  /**
   * 12. The state machine is preparing for a new round
   */
  Restarting = 'restarting',
}
