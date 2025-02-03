
export type PokerTable = {
  m_id: number;
  m_name: string | undefined;
  m_minBuyIn: number;
  m_maxBuyIn: number;
  m_smallBlind: number;
  m_bigBlind: number;
  m_maxPlayers: number;
  m_players: User[],
  m_you: {player: User | undefined, atTable: boolean},
  m_pots: [
    {
      m_total: number,
      m_winningHandsString: [],
      m_winners: [],
    },
  ],
  m_communityCards: Card[],
  m_currentTurn: {index: number | undefined, address: string | undefined},
  m_currentDealer: {index: number | undefined, address: string | undefined},
  m_currentSmallBlind: {index: number | undefined, address: string | undefined},
  m_currentBigBlind: {index: number | undefined, address: string | undefined},
  m_state: string | undefined,
};

export type TableInfo = {
  m_id: number;
  m_name: string | undefined;
  m_minBuyIn: number;
  m_maxBuyIn: number;
  m_smallBlind: number;
  m_bigBlind: number;
  m_maxPlayers: number;
  m_players: string[],
  m_state: string
}

export type User = {
  m_address: string;
  m_balance: number;
  m_state: string;
  m_cards: Card[];
  m_ethereum: number;
};

export type Card = {
  m_rank: string;
  m_suit: string;
};
