import type { PokerClient } from '@frontend/games/poker/client/PokerClient';
import { BaseStarknetPokerClient } from '@frontend/games/poker/client/starknet/BaseStarknetPokerClient';

export class StarknetPokerClient extends BaseStarknetPokerClient implements PokerClient {
  public listRooms: PokerClient['listRooms'] = async ({ offset, limit }) => {
    // TODO: Implement this

    // Here we make a request to the Starknet chain to get the list of rooms

    return [];
  };

  public getRoom: PokerClient['getRoom'] = async ({ roomId }) => {
    // TODO: Implement this
    return {};
  };
}
