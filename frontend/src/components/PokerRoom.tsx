import React from 'react';
import { Observable } from 'rxjs';
import { type ActorRef, createActor, fromEventObservable, type InspectionEvent, type Snapshot } from 'xstate';
import { preFlopAutoActions, refreshRoom } from '@frontend/games/poker/actors';
import { makePokerRoomClient } from '@frontend/games/poker/client';
import type { PokerRoomClient } from '@frontend/games/poker/client/PokerRoomClient';
import { PokerEventType } from '@frontend/games/poker/enums';
import { type ActorRoomState, pokerRoomStateMachine } from '@frontend/games/poker/pokerRoomStateMachine';
import { selectIsWaitingForPlayerAction } from '@frontend/games/poker/selectors';
import { type PokerEvent, type PokerRoomContext } from '@frontend/games/poker/types';
import { PokerRoomCtx, usePokerClient } from '@frontend/games/poker/utils/hooks';
import { useWallet } from '@frontend/providers/ChainsProvider';
import { wait } from '@frontend/library/timing';

interface PokerRoomProps {
  roomId: number;
  children: React.ReactNode;
}

const eventPromiseToActorPromise = (promise: (context: PokerRoomContext) => Promise<PokerEvent | null>) => {
  return fromEventObservable<PokerEvent, PokerRoomContext, PokerEvent>(({ self }) => {
    return new Observable((subscriber) => {
      promise(self._parent!.getSnapshot().context).then((event) => {
        if (event) {
          subscriber.next(event);
        }
      });
    });
  });
};

// const statelyInspector = createBrowserInspector();

const machineLogger = (e: InspectionEvent) => {
  if (e.type === '@xstate.event' && !e.event.type.startsWith('xstate')) {
    console.log('[Poker Machine event]', e.actorRef.getSnapshot().state, e.event.type, e.event.payload);
  }
};

const PokerRoom = ({ roomId, children }: PokerRoomProps) => {
  const wallet = useWallet();
  const pokerClient = usePokerClient();

  // When the page loads, the wallet status is always disconnectd. It then automatically re-connects
  // if possible. This causes multiple re-render of components using the wallet.
  // To avoid this, we introduce a 1 second delay at the start of the loading to let the
  // wallet adapter get to a good state
  const [isReadyToLoad, setIsReadyToLoad] = React.useState(false);
  const [isRoomLoading, setIsRoomLoading] = React.useState(true);

  const [pokerRoomStateActor, setPokerRoomStateActor] = React.useState<ActorRoomState | null>(null);
  const [pokerRoomContext, setPokerRoomContext] = React.useState<PokerRoomContext | null>(null);
  const [pokerRoomClient, setPokerRoomClient] = React.useState<PokerRoomClient | null>(null);

  React.useEffect(() => {
    setTimeout(() => setIsReadyToLoad(true), 1000);
  }, []);

  // ------------------------------------
  // Load room data

  React.useEffect(() => {
    if (!isReadyToLoad || !wallet || !pokerClient) {
      return;
    }

    setIsRoomLoading(true);

    (async () => {
      // Get client for the room
      const roomClient = await makePokerRoomClient(roomId, pokerClient, wallet);

      // Load the current state of the machine, as well as any event that needs to be passed to the machine to be forwarded
      const { context: roomContext, events: pastEvents } = await roomClient.getInitRoomData();

      // To set up our state machine, we perform a two-step process:
      // 1. Create a first machine with no actors, that has therefore no side effects
      // In this machine, apply all the events that already happened in the current round;
      // 2. After the events are applied, we create a new machine using the first machine snapshot,
      // with the real actors this time, enabling side effects;

      // Create our first machine
      const firstMachine = createActor(
        pokerRoomStateMachine.provide({
          actors: {
            prepareRoom: eventPromiseToActorPromise(roomClient.prepareRoom),
            revealOwnCards: eventPromiseToActorPromise(roomClient.revealOwnHand),
            revealCommunityCards: eventPromiseToActorPromise(roomClient.revealCommunityCards),
          },
        }),
        {
          input: { ...roomContext, isPreparing: true },
          inspect: machineLogger, // statelyInspector.inspect,
        },
      );
      firstMachine.start();

      console.log(`[Poker:init] ff ${pastEvents.length} event.s`);
      console.log(pastEvents);

      // Fast-forward all the events to the state machine
      for (const event of pastEvents) {
        // Send the event to the state machine

        // When fast-forwarding, street preparation may need some time to process, and feeding the machine with users actions before the street is ready will
        // make the machine drop these events, which we don't want. so if the machine is not ready, we add an additional delay
        let firstMachineSnapshot = firstMachine.getSnapshot();
        while (
          event.type === PokerEventType.PlayerPerformedAction &&
          !selectIsWaitingForPlayerAction(firstMachineSnapshot.context, firstMachineSnapshot.value)
        ) {
          await wait(50);
          firstMachineSnapshot = firstMachine.getSnapshot();
        }

        console.log(firstMachine.getSnapshot().value, event.type);
        firstMachine.send(event);
        await wait(250);
      }

      firstMachine.send({ type: PokerEventType.PreparingDone });
      await wait(250);

      // All events are applied, we can now create the real machine
      const pokerMachine = createActor(
        pokerRoomStateMachine.provide({
          actors: {
            watchEvents: fromEventObservable(({ self }) =>
              roomClient.getExternalEventsObservable(self as ActorRef<Snapshot<PokerRoomContext>, PokerEvent>),
            ),
            prepareRoom: eventPromiseToActorPromise(roomClient.prepareRoom),
            refreshRoom: refreshRoom({ pokerRoomClient: roomClient }),
            revealOwnCards: eventPromiseToActorPromise(roomClient.revealOwnHand),
            preFlopAutoActions: preFlopAutoActions(roomClient),
            revealCommunityCards: eventPromiseToActorPromise(roomClient.revealCommunityCards),
            revealHand: eventPromiseToActorPromise(roomClient.revealHand),
          },
        }),
        {
          snapshot: firstMachine.getPersistedSnapshot(),
          input: firstMachine.getSnapshot().context,
          inspect: machineLogger,
        },
      );

      firstMachine.stop();

      pokerMachine.subscribe((snapshot) => {
        console.info(
          '[PokerMachine:contextUpdated]',
          snapshot.value,
          snapshot.context,
          snapshot.status,
          snapshot.error,
        );
        setPokerRoomContext(snapshot.context);
      });

      console.debug('[Poker:init] Switching to the real machine');

      pokerMachine.start();

      console.debug('[Poker:init] Fast-forward done. Machine started');

      setPokerRoomStateActor(pokerMachine);
      setPokerRoomClient(roomClient);
      setIsRoomLoading(false);
    })();

    return () => {
      setPokerRoomStateActor((pokerRoomStateActor) => {
        pokerRoomStateActor?.stop();
        return null;
      });
      setPokerRoomContext(null);
      setPokerRoomClient((client) => {
        client?.terminate();
        return null;
      });
    };

    // Disable eslint warning for useEffect as we don't want to include the full `wallet` object, but only the user address
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isReadyToLoad, pokerClient, roomId, wallet?.address]);

  if (isRoomLoading || !pokerRoomContext || !pokerRoomStateActor || !pokerRoomClient) {
    /* TODO: POKER ROOM LOADER GOES HERE */
    return null;
  }

  return (
    <PokerRoomCtx.Provider value={[pokerRoomContext, pokerRoomStateActor, pokerRoomClient]}>
      {children}
    </PokerRoomCtx.Provider>
  );
};

export default PokerRoom;
