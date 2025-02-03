import React, { useEffect, useState } from 'react';
import { useModel, useModels } from '@frontend/chains/starknet/DojoWrapper';
import { StructCard } from '@frontend/dojo/models';
import { GameHeader } from '@frontend/components/table/header/header';
import { LayoutGroup, motion } from 'framer-motion';
import { cn } from '@frontend/utils/cn';
import Coins from '/src/assets/icons/Coins.svg?react';
import Chip from '/src/assets/Chip.svg?react';
import { formatChips } from '@frontend/utils/formatChips';
import { PlayerRow } from '@frontend/routes/room/$roomId.lazy';
import { CardContainer } from '@frontend/components/table/cardContainer';
import { Footer } from '@frontend/components/table/footer/footer';
import { Card, PokerTable, User } from '@frontend/types';
import { useWallet } from '@frontend/providers/ChainsProvider';
import { ThemeSVG } from '@frontend/games/poker/ThemeSelector';
import { AnimatedRoute } from '@frontend/components/routes/animatedRoute';
import { useController } from '@frontend/chains/starknet/hooks';

interface PokerRoomDojoProps {
  roomId: number;
}

// Create masks
const UPPER_MASK = BigInt('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000');
const LOWER_MASK = BigInt('0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');

export const valueToString = (value: number) => {
  switch (value) {
    case 11:
      return 'J';
    case 12:
      return 'Q';
    case 13:
      return 'K';
    case 14:
      return 'A';
    default:
      return value.toString();
  }
};

export const suitToString = (suit: number) => {
  switch (suit) {
    case 1:
      return 'S';
    case 2:
      return 'H';
    case 3:
      return 'D';
    case 4:
      return 'C';
    default: {
      console.error(`Invalid Suit: ${suit}`);
      return suit.toString();
    }
  }
};

export const dojoCardsToCards = (dojoCards: StructCard[] | undefined): Card[] => {
  return (
    dojoCards?.map((card) => {
      const cardBigInt = BigInt(card?.m_num_representation ?? 0);

      // Extract value (upper 128 bits)
      const value = Number((cardBigInt & UPPER_MASK) >> BigInt(128));

      // Extract suit (lower 128 bits)
      const suit = Number(BigInt(cardBigInt) & LOWER_MASK);

      return {
        m_rank: valueToString(value),
        m_suit: suitToString(suit),
      };
    }) ?? []
  );
};

export const PokerRoomDojo = ({ roomId }: PokerRoomDojoProps) => {
  const wallet = useWallet();
  const { connector } = useController();
  const [isReadyToLoad, setIsReadyToLoad] = useState(false);
  const [isRoomLoading, setIsRoomLoading] = useState(true);
  const [theme, setTheme] = useState('neon'); // Default theme

  const available = connector?.available();

  // Subscribe to the specific table
  const table = useModel([roomId], 'ComponentTable');
  const dojoHand = useModel([wallet?.address ?? "0x0"], 'ComponentHand');

  // Subscribe to all players in this table
  const allPlayers = useModels('ComponentPlayer')
    .filter(player => player?.m_table_id === roomId);

  const you = useModel([roomId, wallet?.address ?? "0x0"],"ComponentPlayer");

  const [users, setUsers] = useState<User[]>([]);
  const [atTable, setAtTable] = useState(false);
  const [currentPlayer, setCurrentPlayer] = useState<User>();

  // When the page loads, wait for wallet connection
  useEffect(() => {
    setTimeout(() => setIsReadyToLoad(true), 1000);
  }, []);

  // Load room data
  useEffect(() => {
    if (!isReadyToLoad || !wallet) {
      return;
    }

    if (!table || table.m_state.toString() === "Shutdown") {
      console.error(`[PokerRoom]: Table ${roomId} is shutdown or does not exist`);
      return;
    }

    setIsRoomLoading(false);
  }, [isReadyToLoad, wallet, table]);

  // Debug logging
  useEffect(() => {
    const tablePlayers: User[] = allPlayers
      .filter((player) => player && player.m_state.toString() !== "Left")
      .map(player => {
        return {
          m_address: player?.m_owner ?? '0x0',
          m_balance: Number(player?.m_table_chips ?? 0),
          m_state: player?.m_state.toString() ?? "Left",
          m_cards: dojoCardsToCards(dojoHand?.m_cards),
          m_ethereum: Number(player?.m_table_chips ?? 0),
        }
      });

    const youAsUser: User = {
      m_address: you?.m_owner ?? '0x0',
      m_balance: Number(you?.m_total_chips ?? 0),
      m_state: you?.m_state.toString() ?? "Waiting",
      m_cards: dojoCardsToCards(dojoHand?.m_cards),
      m_ethereum: Number(you?.m_table_chips ?? 0),
    }

    const isAtTable = tablePlayers.find((player => player?.m_address === wallet?.address));

    // Get current player if they're in the game
    setAtTable(isAtTable !== undefined);
    setCurrentPlayer(youAsUser);
    setUsers(tablePlayers);

    console.log(`[PokerRoom]: Table: `, table);
    console.log(`[PokerRoom]: Is at table?: `, atTable);
  }, [roomId, wallet?.status, available]);

  if (!table || table.m_state.toString() === 'Shutdown') {
    console.error(`Table ${roomId} is shutdown or does not exist`);
    return (
      <div className='text-text-primary flex h-full flex-col items-center justify-center'>
        {`Table ${roomId} does not exist or is shutdown, please select another room...`}
      </div>
    );
  }
  if (isRoomLoading) {
    return (
      <div className='text-text-primary bg-secondary flex h-full flex-col items-center justify-center'>
        Loading poker room...
      </div>
    );
  }

  const tableContext: PokerTable = {
    m_id: roomId,
    m_name: undefined,
    m_minBuyIn: Number(table?.m_min_buy_in),
    m_maxBuyIn: Number(table?.m_max_buy_in),
    m_players: users,
    m_maxPlayers: 6,
    m_you: {player: currentPlayer, atTable: atTable},
    m_smallBlind: Number(table?.m_small_blind),
    m_bigBlind: Number(table?.m_big_blind),
    m_pots: [
      {
        m_total: Number(table?.m_pot ?? 0),
        m_winningHandsString: [],
        m_winners: [],
      },
    ],
    m_communityCards: dojoCardsToCards(table?.m_community_cards),
    m_currentTurn: {
      index: Number(table?.m_current_turn),
      address: table?.m_players.at(Number(table?.m_current_turn)),
    },
    m_currentDealer: {
      index: Number(table?.m_current_dealer),
      address: table?.m_players[Number(table?.m_current_dealer)],
    },
    m_currentSmallBlind: {
      index: table ? Number(table.m_current_dealer) + 1 : undefined,
      address: table?.m_players[Number(table?.m_current_dealer) + 1],
    },
    m_currentBigBlind: {
      index: table ? Number(table.m_current_dealer) + 2 : undefined,
      address: table?.m_players[Number(table?.m_current_dealer) + 2],
    },
    m_state: table?.m_state.toString(),
  };

  return (
    <div className='relative h-screen overflow-hidden'>
      <GameHeader
        room={roomId}
        theme={theme}
        setTheme={(theme) => {
          setTheme(theme);
        }}
        user={tableContext.m_you}
      />

      {/* Table */}
      <motion.div
        layout
        className={cn(
          'relative z-10 flex shrink-0 flex-grow flex-col items-center justify-center overflow-hidden',
          'h-xs:justify-center justify-start',
        )}
      >
        <motion.div
          layout
          className='h-xs:gap-y-4 z-10 grid w-full max-w-xl grid-cols-9 grid-rows-[repeat(6,minmax(0,auto))] gap-y-2 px-2 py-4'
        >
          {/* Player Details */}
          <PlayerRow players={tableContext.m_players.slice(0, 2)} />

          {/* Pot Row */}
          <motion.div layout='position' className='col-span-9 flex items-center justify-center'>
            <div className='bg-secondary flex flex-col items-center justify-center rounded-md px-4 py-2'>
              <span className='flex items-center gap-1'>
                <Coins />
                <h1 className='text-text-tertiary text-xs font-light'>POT</h1>
              </span>
              <span className='flex items-center gap-1'>
                <Chip className='w-4' />
                <h2 className='text-text-secondary text-lg font-medium'>
                  {formatChips(tableContext.m_pots[0]?.m_total ?? 0)} Chips
                </h2>
              </span>
            </div>
          </motion.div>

          {/* Player Details */}
          <PlayerRow players={tableContext.m_players.slice(2, 4)} />

          {/* Community Cards */}
          <LayoutGroup>
            <motion.div
              layout
              className='col-span-9 row-span-2 grid w-full grid-cols-[repeat(5,minmax(0,auto))] items-center gap-2 px-8'
            >
              {Array.from({ length: 5 }).map((_, i) => (
                <CardContainer layout key={`community-card-${i}`} card={tableContext.m_communityCards?.at(i)} />
              ))}
            </motion.div>
          </LayoutGroup>

          {/* Player Details */}
          <PlayerRow players={tableContext.m_players.slice(4, 6)} />
        </motion.div>
      </motion.div>

      {/* Footer */}
      {wallet && <Footer
        user={tableContext.m_you}
        isSeated={tableContext.m_you?.atTable}
        table={tableContext}
      />}

      {/* Table Background */}
      <motion.div
        layout='position'
        className='absolute -bottom-20 z-0 flex h-full w-full items-start justify-center'
        style={{ perspective: 1000 }}
      >
        <ThemeSVG theme={theme} className='w-11/12' style={{ transform: 'rotateX(15deg) scaleY(1.2)' }} />
      </motion.div>
    </div>
  );
};
