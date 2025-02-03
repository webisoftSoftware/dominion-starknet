import type { Address } from '@frontend/chains/types';

export type MaskedDeck = string[];

export type Deck = {
  signature?: string;
  publicKey: string;
  seatIndex?: number;
  shuffledDeck: MaskedDeck;
  shuffledDeckProof: string;
};

export type Rank =
  | 'Ace'
  | 'King'
  | 'Queen'
  | 'Jack'
  | 'Ten'
  | 'Nine'
  | 'Eight'
  | 'Seven'
  | 'Six'
  | 'Five'
  | 'Four'
  | 'Three'
  | 'Two';

export type Suit = 'Spade' | 'Club' | 'Heart' | 'Diamond';

export type RevealToken = [card: string, revealToken: string, revealTokenProof: string, publicKey: number[]];
export type PlayerRevealTokens = {
  sender: Address;
  tokens: Record<Address, [RevealToken, RevealToken]>;
};
export type CommunityRevealTokens = {
  sender: Address;
  tokens: [RevealToken, RevealToken, RevealToken] | [RevealToken]; // 3 or 1 tokens for flop (3), turn (1), river (1)
};

export type Card = {
  value: Rank;
  suit: Suit;
};
