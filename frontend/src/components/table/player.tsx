import { User } from '@frontend/types';
import { cn } from '@frontend/utils/cn';
import { formatChips } from '@frontend/utils/formatChips';
import { motion } from 'framer-motion';

import Chip from '../../assets/Chip.svg?react';
import CardsHidden from '../../assets/CardsHidden.svg?react';

const PlayerProfile = ({ player, isMe }: { player?: User; isMe?: boolean }) => {
  return (
    <motion.div layout='position' className='relative z-0 col-span-2 flex flex-col items-center justify-center'>
      <div className='bg-primary border-tertiary h-xs:h-20 h-xs:w-20 -z-10 col-span-2 h-16 w-16 rounded-full border-2 sm:h-24 sm:w-24' />

      {player && (
        <>
          <CardsHidden className='absolute bottom-2 -z-10 w-1/2' />
          <div className='bg-primary border-tertiary text-text-secondary -mt-4 flex w-full items-center justify-center gap-1 rounded-full border-[1px] px-2 py-0.5 text-xs sm:text-base'>
            {isMe ? (
              'You'
            ) : (
              <>
                <Chip className='w-3 sm:w-4' /> {formatChips(player.m_balance)}
              </>
            )}
          </div>
        </>
      )}
    </motion.div>
  );
};
const PlayerInfo = ({ reverse }: { player?: User; reverse?: boolean }) => {
  return <motion.div layout='position' className={cn('col-span-2', reverse && '-order-1')} />;
};

export const Player = ({ player, reverse, isMe }: { player?: User; reverse?: boolean; isMe?: boolean }) => {
  return (
    <div className='col-span-4 grid grid-cols-subgrid gap-4'>
      <PlayerProfile player={player} isMe={isMe} />
      <PlayerInfo player={player} reverse={reverse} />
    </div>
  );
};
