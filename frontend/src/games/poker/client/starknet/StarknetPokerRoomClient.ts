import { Observable } from 'rxjs';
import type { ActorRef, Snapshot } from 'xstate';

import type { WalletAccount } from '@frontend/chains/types';
import type { PokerRoomClient } from '@frontend/games/poker/client/PokerRoomClient';
import type { ChatMessage } from '@frontend/games/poker/resources/messages';
import { PlayerAction, PokerEvent, PokerRoomContext } from '../../types';
import { BaseStarknetPokerClient } from '@frontend/games/poker/client/starknet/BaseStarknetPokerClient';
import { StarknetClient } from '@frontend/chains/starknet/StarknetClient';
import { getCleanPokerRoomContext } from '../../utils/context';
import { DojoProvider } from '@dojoengine/core';
import { setupWorld } from '@frontend/dojo/contracts';
import { dojoConfig } from '@frontend/dojo/dojoConfig';
import { ToriiClient } from '@dojoengine/torii-client';

export const TABLE_MANAGER_CONTRACT_ADDRESS =
  "0x006d1c3ee5e1a867bca0101bd8a34efea4801839ac0c7d3128eb662aca7a1efc";
export const ACTIONS_CONTRACT_ADDRESS = "0x07ca85535b7cbccfc548c71b2e3c9cf45b4b38963488f52fdf5770a38b37fec7";
export const CASHIER_CONTRACT_ADDRESS = "0x04f729d85db5cb7fb3b05f6e436ea53783363590c05edfd4a4ac5e736c423bc9";

export class StarknetPokerRoomClient extends BaseStarknetPokerClient implements PokerRoomClient {
  protected readonly roomId: number;
  protected readonly wallet: WalletAccount | null;
  protected readonly torii: ToriiClient;
  protected contracts: unknown;

  constructor(client: StarknetClient, toriiClient: ToriiClient, roomId: number, wallet: WalletAccount | null) {
    super(client);
    this.roomId = roomId;
    this.wallet = wallet;
    this.torii = toriiClient;
    this.contracts = setupWorld(new DojoProvider(dojoConfig.manifest, dojoConfig.rpcUrl));
  }

  public async terminate() {
    // Cleanup any subscriptions if needed
  }

  // MARK: - Chat

  public hasChat() {
    //No chat for starknet for now
    return false;
  }

  public async sendChatMessage(message: ChatMessage) {
    //No chat for starknet for now
    return;
  }

  // async dojoEventsToPokerEvents(): Promise<PokerEvent[]> {
  //   // Filter events from chain to only query the ones relevant to this room.
  //   const events: Record<string, Entity> = await this.torii.getEventMessages(
  //     {
  //       clause: {
  //         Keys: {
  //           keys: [undefined], // table id
  //           pattern_matching: 'VariableLen',
  //           models: [],
  //         },
  //       },
  //       dont_include_hashed_keys: false,
  //       entity_models: ['dominion-ComponentTable', 'dominion-ComponentPlayer', 'dominion-ComponentHand'],
  //       entity_updated_after: 0,
  //       limit: 100,
  //       offset: 1,
  //       order_by: [
  //         {
  //           model: 'dominion-ComponentTable',
  //           member: 'm_table_id',
  //           direction: 'Asc',
  //         },
  //       ],
  //     },
  //     true,
  //   );
  //   console.log('events', events);
  //
  //   const pokerEvents: PokerEvent[] = [];
  //   for (const entity in events) {
  //     for (const model in events[entity]) {
  //       console.log(model);
  //       switch (model) {
  //         case 'dominion-EventAllPlayersReady':
  //           pokerEvents.push({
  //             type: PokerEventType.RoomIsReady,
  //             payload: {
  //               roomId: this.roomId,
  //               roundId: 0,
  //             },
  //           });
  //           break;
  //         case 'dominion-EventPlayerJoined':
  //           pokerEvents.push({
  //             type: PokerEventType.PlayerJoined,
  //             payload: {
  //               roomId: this.roomId,
  //               roundId: 0,
  //               isPreparing: true,
  //               seatsCount: 6,
  //               playerAddress: model["m_owner"],
  //               contractAddress: ACTIONS_CONTRACT_ADDRESS,
  //               players: Player[]   waitingPlayers: Player[]   activeSeatIndex: number | null
  //             },
  //           });
  //       }
  //     }
  //   }
  //   return pokerEvents;
  // }

  public async getInitRoomData(): Promise<{ context: PokerRoomContext; events: PokerEvent[] }> {
    const cleanContext = getCleanPokerRoomContext();
    return {
      context: {
        ...cleanContext,
        roomId: this.roomId,
        roundId: 0,
        playerAddress: this.wallet?.address ?? '',
        seatsCount: 6,
        contractAddress: TABLE_MANAGER_CONTRACT_ADDRESS,
        // Map other table data as needed
      },
      events: [] as PokerEvent[],
    };
  }

  /**
   * Returns an observable that listens to external events for the game room
   */
  public getExternalEventsObservable(
    machine: ActorRef<Snapshot<PokerRoomContext>, PokerEvent>,
  ): Observable<PokerEvent> {
    return new Observable<PokerEvent>();
  }

  public async getRoom(): Promise<Partial<PokerRoomContext>> {
    // const starknetClient = this.getClient() as StarknetClient;
    //
    // const table = starknetClient.queryEntity(
    //   [this.roomId],
    //   ModelsMapping.ComponentTable
    // );
    //
    // const player = this.wallet && this.wallet.address ? starknetClient.queryEntity(
    //   [this.roomId, this.wallet.address],
    //   ModelsMapping.ComponentPlayer
    // ) : undefined;
    //
    // if (!table) {
    //   return {};
    // }
    //
    // return {
    //   roomId: this.roomId,
    //   playerAddress: player?.m_owner,
    //   // Map other table and player data to PokerRoomContext
    //   minimumTableEntryBalance: Number(table.m_min_buy_in),
    //   smallBlind: Number(table.m_small_blind),
    //   pots: [{
    //     total: Number(table.m_pot),
    //     winningHandsString: [],
    //     winners: []
    //   }]
    // };
    return {};
  }

  public joinRoom = async (seatIndex: number, buyInAmount: number): Promise<boolean> => {
    const starknetClient = this.getClient() as StarknetClient;
    // Implement join room logic using starknet client
    return false;
  };

  public leaveRoom = async () => {
    const starknetClient = this.getClient() as StarknetClient;
    // Implement leave room logic using starknet client
    return true;
  };

  public prepareRoom = async (state: PokerRoomContext): Promise<PokerEvent | null> => {
    //TODO: Implement this
    return null;
  };

  public revealOwnHand = async (state: PokerRoomContext): Promise<PokerEvent | null> => {
    //TODO: Implement this
    return null;
  };

  public revealCommunityCards = async (state: PokerRoomContext): Promise<PokerEvent | null> => {
    //TODO: Implement this
    return null;
  };

  public sendGameAction = async (action: PlayerAction): Promise<PokerEvent | null> => {
    //TODO: Implement this
    return null;
  };

  public revealHand = async (state: PokerRoomContext): Promise<PokerEvent | null> => {
    //TODO: Implement this
    return null;
  };
}
