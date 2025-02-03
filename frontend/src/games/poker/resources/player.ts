import type { PokerAction } from '@frontend//games/poker/enums';
import type { Card } from './cards';

export type PlayerEntity = {
  id: string;
  seatIndex?: number;  //
  listIndex: number;  // Order while excluding empty seats.
  didWin?: boolean;
  didFold?: boolean;
  isAllIn?: boolean;
  openCards?: [Card, Card];  // Player's decrypted cards.
  maskedCards?: [string, string];  // Encrypted card
  balance: string;
  address: string;
  canCheck?: boolean;
  isDealer?: boolean;
  isSmallBlind?: boolean;
  isBigBlind?: boolean;
};

export type Player = Omit<
  PlayerEntity,
  'didWin' | 'didFold' | 'isAllIn' | 'cards' | 'balance' | 'betInStreet' | 'totalBetInRound'
> & {
  name: string;
  balance: number;
  totalBetInRound: number;
  betInStreet: number;
  avatar: string;
  allInAmount?: number;
  isActive?: boolean;
  roundAction: PokerAction | null;
};

