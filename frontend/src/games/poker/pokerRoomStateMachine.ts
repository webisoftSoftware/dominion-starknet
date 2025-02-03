import { produce } from 'immer';
import toast from 'react-hot-toast';
import { Actor, assign, enqueueActions, fromEventObservable, fromPromise, setup } from 'xstate';

import { handlePlayerAction } from '@frontend/games/poker/actions/handlePlayerAction';
import { PokerAction, PokerEventType, PokerState } from '@frontend/games/poker/enums';
import { POKER_PARAMS } from '@frontend/games/poker/params';
import { selectPlayersInOrder } from '@frontend/games/poker/selectors';
import type { PokerEvent, PokerRoomContext } from '@frontend/games/poker/types';
import { resetContext } from '@frontend/games/poker/utils/context';
import { uniqBy } from '@frontend/library/arrays';
import { Player } from '@frontend/games/poker/resources/player';

const emptyEventObservable = <Input = PokerRoomContext>() =>
  fromEventObservable<PokerEvent, Input, PokerEvent>(() => ({
    subscribe: () => ({ unsubscribe: () => null }),
  }));

export const pokerRoomStateMachine = setup({
  types: {} as {
    context: PokerRoomContext;
    events: PokerEvent;
    input: PokerRoomContext;
  },
  actions: {
    finalizeRoundPreparation: enqueueActions(({ context, enqueue }) => {
      // Set the activeSeatIndex to the first player to play
      const smallBlindPlayer = context.players.find((p) => p.isSmallBlind);
      enqueue.assign({ activeSeatIndex: smallBlindPlayer?.seatIndex });
    }),
    handlePlayerAction: handlePlayerAction() as any,
    resetPlayerActions: assign(({ context }) => ({
      players: context.players.map((p) => ({
        ...p,
        roundAction: p.roundAction !== PokerAction.Fold && p.roundAction !== PokerAction.AllIn ? null : p.roundAction,
      })),
    })),
  },
  actors: {
    // For many actors we use `fromEventObservable` instead of `fromPromise` to make sure these actor invocations are restarted when switching from the first, event-less machine to the real one,
    // If we were using regular Promise actors, they would be marked as done when they resolved, and would not be restarted when switching to the main machine
    watchEvents: emptyEventObservable(),
    prepareRoom: emptyEventObservable(),
    refreshRoom: fromPromise<Partial<PokerRoomContext>, PokerRoomContext, PokerEvent>(async () => ({}) as any),
    revealOwnCards: emptyEventObservable(),
    preFlopAutoActions: emptyEventObservable(),
    revealCommunityCards: emptyEventObservable(),
    revealHand: emptyEventObservable(),
  },
}).createMachine({
  context: ({ input }) => ({
    ...input,
    activeSeatIndex: null,
    shuffledDecks: [],
    communityCards: [],
    revealTokens: [],
    pots: [],
    showdownActivePotIndex: null,
  }),
  id: 'poker',
  initial: 'idle',
  invoke: [
    {
      // This invocation watches for events outside and sends them to the state machine
      id: 'watchEvents',
      src: 'watchEvents',
      input: ({ context }) => context,
    },
  ],
  states: {
    [PokerState.Idle]: {
      // This is the default state when the game is not in progress, when we are waiting for users to join
      always: [
        {
          guard: ({ context }) => context.players.length >= 2,
          target: PokerState.PreparingRoom,
        },
      ],
      on: {
        [PokerEventType.PlayerJoined]: {
          actions: [assign(({ event }) => event.payload), () => toast('Player joined')],
          target: PokerState.Idle,
          reenter: true,
        },
        [PokerEventType.NewGameStarted]: {
          target: PokerState.PreparingRoom,
        },
      },
    },
    [PokerState.PreparingRoom]: {
      invoke: {
        src: 'prepareRoom',
        input: ({ context }) => context,
      },
      on: {
        [PokerEventType.RoomStateUpdated]: {
          actions: assign(({ context, event }) => event.payload(context)),
          target: PokerState.PreparingRoom,
          reenter: true,
        },
        [PokerEventType.RoomIsReady]: {
          actions: assign(({ event }) => ({ ...event.payload })),
          target: PokerState.RevealingOwnCards,
        },
      },
    },
    [PokerState.RevealingOwnCards]: {
      // Using the received reveal tokens, players can now reveal their own cards
      invoke: {
        src: 'revealOwnCards',
        input: ({ context }) => context,
      },
      on: {
        [PokerEventType.RoomStateUpdated]: {
          actions: assign(({ context, event }) => event.payload(context)),
          target: PokerState.RevealingOwnCards,
          reenter: true,
        },
        [PokerEventType.OwnCardsRevealed]: {
          actions: [
            assign(({ context, event }) => {
              return {
                players: produce(context.players, (players) => {
                  const player = players.find((p: Player) => p.address === context.playerAddress)!;
                  player.openCards = event.payload.cards;
                }),
              };
            }),
            () => toast('Hand revealed'),
          ],
          target: PokerState.Ready,
        },
        [PokerEventType.UserIsSpectator]: {
          target: PokerState.Ready,
        },
      },
    },
    [PokerState.Ready]: {
      // The game is ready to begin
      entry: [
        {
          type: 'finalizeRoundPreparation',
        },
      ],
      always: {
        target: PokerState.PreFlop,
      },
    },
    [PokerState.PreFlop]: {
      initial: PokerState.StreetPendingAction,
      entry: [() => toast('Begin Pre-Flop')],
      states: {
        [PokerState.StreetPendingAction]: {
          invoke: {
            src: 'preFlopAutoActions',
            input: ({ context }) => context,
          },
          on: {
            [PokerEventType.PlayerPerformedAction]: {
              actions: [
                assign(({ context, event }) => ({
                  playerActions: [...context.playerActions, event.payload],
                })),
              ],
              target: PokerState.StreetProcessingAction,
            },
          },
        },
        [PokerState.StreetProcessingAction]: {
          entry: [{ type: 'handlePlayerAction' }],
          on: {
            [PokerEventType.NextPlayerTurn]: {
              actions: [
                assign(({ event }) => ({
                  activeSeatIndex: event.payload.nextSeatIndex,
                })),
              ],
              target: PokerState.StreetPendingAction,
            },
            [PokerEventType.EndOfStreet]: PokerState.StreetDone,
            [PokerEventType.EndOfGame]: {
              target: '#' + PokerState.Showdown,
            },
          },
        },
        [PokerState.StreetDone]: {
          type: 'final',
        },
      },
      onDone: {
        actions: [
          assign({
            street: PokerState.Flop,
          }),
        ],
        target: PokerState.Street,
      },
    },
    [PokerState.Street]: {
      id: PokerState.Street,
      entry: [{ type: 'resetPlayerActions' }, ({ context }) => toast(`Begin ${context.street}`)],
      initial: PokerState.PreparingStreet,
      states: {
        [PokerState.PreparingStreet]: {
          // We need to reveal community cards,
          invoke: {
            src: 'revealCommunityCards',
            input: ({ context }) => context,
          },
          on: {
            [PokerEventType.RoomStateUpdated]: {
              actions: assign(({ context, event }) => event.payload(context)),
              target: PokerState.PreparingStreet,
              reenter: true,
            },
            [PokerEventType.CommunityCardsRevealed]: {
              actions: [
                assign(({ context, event }) => ({
                  communityCards: [...context.communityCards, ...event.payload.cards],
                })),
              ],
              target: PokerState.StreetStart,
            },
          },
        },
        [PokerState.StreetStart]: {
          // On every street except the first one, the first player to play is the first player after (clockwise) after the dealer.
          // This is usually the small blind, execpt when the small blind is also the dealer, in this case it is the big blind.
          // If any of these players are not playing, we skip them and move to the next one that can play
          always: {
            actions: [
              assign(({ context }) => {
                const players = selectPlayersInOrder(
                  context as PokerRoomContext,
                  { [context.street!]: PokerState.StreetStart } as any,
                );
                return {
                  activeSeatIndex: players[0]!.isDealer ? players[1]!.seatIndex : players[0]!.seatIndex,
                };
              }),
            ],
            target: PokerState.StreetPendingAction,
          },
        },
        [PokerState.StreetPendingAction]: {
          on: {
            [PokerEventType.PlayerPerformedAction]: {
              actions: [
                assign(({ context, event }) => ({
                  playerActions: [...context.playerActions, event.payload],
                })),
              ],
              target: PokerState.StreetProcessingAction,
            },
          },
        },
        [PokerState.StreetProcessingAction]: {
          entry: [{ type: 'handlePlayerAction' }],
          on: {
            [PokerEventType.NextPlayerTurn]: {
              actions: [
                assign(({ event }) => ({
                  activeSeatIndex: event.payload.nextSeatIndex,
                })),
              ],
              target: PokerState.StreetPendingAction,
            },
            [PokerEventType.EndOfStreet]: [
              {
                // Go to next street
                guard: ({ context }) => context.street === PokerState.Flop || context.street === PokerState.Turn,
                actions: [
                  assign(({ context }) => ({
                    street: context.street === PokerState.Flop ? PokerState.Turn : PokerState.River,
                  })),
                ],
                target: '#' + PokerState.Street,
                reenter: true,
              },
              {
                // Or go to showdown
                guard: ({ context }) => context.street === PokerState.River,
                target: '#' + PokerState.Showdown,
              },
            ],
            [PokerEventType.EndOfGame]: {
              target: '#' + PokerState.Showdown,
            },
          },
        },
        [PokerState.StreetDone]: {
          type: 'final',
        },
      },
    },
    [PokerState.Showdown]: {
      id: PokerState.Showdown,
      invoke: {
        src: 'revealHand',
        input: ({ context }) => context,
      },
      on: {
        [PokerEventType.RoomStateUpdated]: {
          actions: assign(({ context, event }) => event.payload(context)),
          target: PokerState.Showdown,
          reenter: true,
        },
        [PokerEventType.FinalEvalReceived]: {
          actions: [
            assign(({ event }) => ({
              endGameAttributes: event.payload,
            })),
          ],
          target: PokerState.EndRound,
        },
      },
    },
    [PokerState.EndRound]: {
      after: {
        [POKER_PARAMS.NEW_ROUND_DELAY_MS]: {
          target: PokerState.Restarting,
        },
      },
    },
    [PokerState.Restarting]: {
      invoke: {
        src: 'refreshRoom',
        input: ({ context }) => context,
        onDone: {
          actions: assign(({ context, event }) => {
            return resetContext(context, event.output);
          }),
          target: PokerState.Idle,
        },
      },
    },
  },
  on: {
    [PokerEventType.PlayerWaiting]: {
      actions: assign(({ event }) => ({
        waitingPlayers: event.payload.players,
      })),
    },
    [PokerEventType.PlayerLeft]: {
      actions: assign(({ context, event }) => ({
        players: context.players.splice(
          context.players.findIndex((p) => p.address === event.payload.address),
          1,
        ),
      })),
    },
    [PokerEventType.ChatReceived]: {
      actions: assign(({ context, event }) => ({
        chatMessages: [...event.payload, ...context.chatMessages],
      })),
    },
    [PokerEventType.RevealToken]: {
      actions: assign(({ context, event }) => ({
        revealTokens: uniqBy([...context.revealTokens, event.payload], (tokens) => tokens.sender),
      })),
    },
    [PokerEventType.PreparingDone]: {
      actions: assign(() => ({ isPreparing: false })),
    },
  },
});
/**
 * Type for the main machine state
 */
export type ActorRoomState = Actor<typeof pokerRoomStateMachine>;
