import { StarknetClient } from '@frontend/chains/starknet/StarknetClient';
import { ChainType } from '@frontend/chains/types';

export class BaseStarknetPokerClient {
  protected readonly client: StarknetClient;

  constructor(client: StarknetClient) {
    this.client = client;
  }

  public getClient(): StarknetClient {
    return this.client;
  }

  public getChainType(): ChainType {
    return this.getClient().getChainType();
  }

  public getChainId(): string {
    return this.getClient().getChainId();
  }
}
