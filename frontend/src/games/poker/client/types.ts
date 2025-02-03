import type { RevealToken } from '@frontend/games/poker/resources/cards';

export type QueryFn<Params, Result> = (params: Params) => Promise<Result>;
export type QueryFnParams<Type> = Type extends QueryFn<infer Params, any> ? Params : never;
export type QueryFnResult<Type> = Type extends QueryFn<any, infer Result> ? Result : never;

export interface ProofOfhand {
  /**
   * Action pubkey of the player
   */
  action_pub_key: string;

  /**
   * The reveal token tuples to reveal the cards, grouped by cards
   * [
   *   // Card 1
   *   [
   *     [...], // Reveal Token 1
   *     [...], // Reveal Token 2
   *     ...
   *   ],
   *   // Card 2
   *   [
   *     [...], // Reveal Token 1
   *     [...], // Reveal Token 2
   *     ...
   *   ]
   * ]
   */
  proofs: RevealToken[][];
}
