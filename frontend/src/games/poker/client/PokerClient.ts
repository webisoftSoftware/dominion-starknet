import type { ChainType } from '@frontend/chains/types';
import type { QueryFn } from '@frontend/games/poker/client/types';
import type { PokerRoomContext } from '@frontend/games/poker/types';
import { RoomListItem } from '@frontend/games/poker/resources/room';

export interface PokerClient {
  /**
   * Returns the type of the chain
   */
  getChainType: () => ChainType;

  /**
   * Returns the ID of the chain
   */
  getChainId: () => string;

  /**
   * Returns a list of all the rooms available on the chain
   */
  listRooms: QueryFn<{ offset?: number; limit?: number }, RoomListItem[]>;

  /**
   * Returns the data for the room, type is declared as partial to give some flexibility to each chain implementation
   */
  getRoom: QueryFn<{ roomId: number }, Partial<PokerRoomContext>>;
}
