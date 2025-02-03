import { PokerTable, User } from '@frontend/types';
import { AnimatePresence, motion } from 'framer-motion';
import { CardContainer } from '../cardContainer';
import { GameState } from './gameState';
import { Button } from '@frontend/components/button';
import { PlayerAction } from './playerAction';
import { formatChips } from '@frontend/utils/formatChips';

import Chip from '../../../assets/Chip.svg?react';
import { JoinTableModel } from '@frontend/components/lobby/joinTableModal';
import { useState } from 'react';
import { useModel } from '@frontend/chains/starknet/DojoWrapper';
import { dojoCardsToCards } from '@frontend/components/PokerRoomDojo';

export interface FooterProps {
  isSeated: boolean;
  table: PokerTable;
  user: {player: User | undefined, atTable: boolean};
}

export const Footer = ({ user, table }: FooterProps) => {
  const [showJoinTableModal, setShowJoinTableModal] = useState(false);
  const dojoHand = useModel([user.player?.m_address ?? '0x0'], 'ComponentHand');
  const hand = dojoCardsToCards(dojoHand?.m_cards);

  console.log(`[FOOTER]: Player state: ${user.player}, User: `, user);

  return (
    <>
      <motion.div className='fixed bottom-0 border-[2px] border-secondary rounded-md z-50 w-[98%] max-w-[635px]'>
        {/* Hand */}
        {user.player?.m_state === "Active" && (
          <motion.div layout className='absolute -z-10 flex justify-center'>
            <motion.div
              animate={{ y: table.m_currentTurn?.address === user.player?.m_address ? '-40%' : '-70%' }}
              transition={{
                type: 'spring',
                damping: 30,
                stiffness: 200,
                delay: 0.1,
              }}
              className='bg-secondary h-xs:gap-3 h-xs:p-3 h-xs:h-40 flex h-28 gap-2 rounded-2xl p-2'
            >
              <CardContainer key='user-card-0' card={hand ? hand[0] : undefined} />
              <CardContainer key='user-card-1' card={hand ? hand[1] : undefined} />
            </motion.div>
          </motion.div>
        )}

        <motion.div layout className='bg-secondary z-20 px-2 mt-auto w-full flex flex-col m-auto pt-4'>
          <motion.div layout='position' className='flex items-center w-full flex-grow justify-between px-1 pb-4'>
            <GameState table={table} />
            {user.player?.m_state === "Active" ? (
              <div className='text-text-secondary flex items-center gap-1'>
                <p className='text-xs font-thin'>Available Chips:</p>
                <Chip className='w-4' />
                <p className='text-xs'>{formatChips(user.player?.m_balance ?? 0)}</p>
              </div>
            ) : user.player?.m_state === "Waiting" ? (
              <Button variant='primary' compact>
                <p className='text-text-primary text-xs font-medium'>Ready Up</p>
              </Button>
              ) : table.m_players.length === 6 ? (
                <Button variant='primary' className={"ml-5"} compact disabled={true}>
                  <p className='text-text-primary text-xs font-medium'>Waiting for an open spot...</p>
                </Button>
              ) : (
              <Button variant='primary' className={"ml-5"} compact onClick={() => setShowJoinTableModal(true)}>
                <p className='text-text-primary text-xs font-medium'>Join Table</p>
              </Button>
              )
            }
          </motion.div>

          {/* Player Action */}
          <AnimatePresence>{table.m_currentTurn.address === user.player?.m_address &&
            <PlayerAction room={table.m_id} player={user.player} />
          }</AnimatePresence>
        </motion.div>
      </motion.div>
      {user && !user.atTable && table.m_players.length !== 6 && (
        <JoinTableModel
          table={{
            m_id: table.m_id,
            m_name: table.m_name,
            m_state: table.m_state ?? "Shutdown",
            m_players: table.m_players.map(player => player.m_address),
            m_minBuyIn: table.m_minBuyIn,
            m_maxBuyIn: table.m_maxBuyIn,
            m_smallBlind: table.m_smallBlind,
            m_bigBlind: table.m_bigBlind,
            m_maxPlayers: table.m_maxPlayers
          }}
          user={user.player}
          visible={showJoinTableModal}
          onClose={() => setShowJoinTableModal(false)}
        />
      )}
    </>
  );
};
