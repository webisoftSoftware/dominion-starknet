import { type Card } from '@frontend/types';
import { cn } from '@frontend/utils/cn';
import { motion } from 'framer-motion';

import Heart from '../../assets/suits/Heart.svg?react';
import Diamond from '../../assets/suits/Diamond.svg?react';
import Club from '../../assets/suits/Club.svg?react';
import Spade from '../../assets/suits/Spade.svg?react';

const suits = {
  heart: Heart,
  diamond: Diamond,
  club: Club,
  spade: Spade,
};

type SuitProps = React.SVGProps<SVGSVGElement> & {
  suit: Card['m_suit'];
};
const Suit = ({ suit, ...props }: SuitProps) => {
  const Icon = suits[suit];

  return <Icon {...props} />;
};

export const CardContainer = ({ card, layout }: { card?: Card; layout?: boolean }) => {
  return (
    <motion.div
      layout={layout}
      className={cn(
        'bg-tertiary border-text-disabled relative z-0 aspect-[0.65] min-w-12 max-w-20 rounded-xl border-[1px] border-dashed p-1.5',
        card && 'border-none bg-white',
      )}
    >
      {card && (
        <>
          <div className='absolute left-1 top-1 z-10 flex flex-col items-center rounded-br-full bg-white pb-1 pr-1'>
            <p className='text-tertiary text-[0.6rem]'>{card.m_rank}</p>
            <Suit suit={card.m_suit} className='h-2 w-2 overflow-visible' />
          </div>

          <div className='border-tertiary/5 flex h-full flex-1 flex-col items-center overflow-clip rounded-md border-[3px] border-double'>
            <div className='bg-tertiary/5 relative flex w-full flex-1 items-center justify-center p-1'>
              <Suit suit={card.m_suit} className='h-1/3 overflow-visible' />
            </div>
          </div>

          <div className='absolute bottom-1 right-1 z-10 flex rotate-180 flex-col items-center rounded-br-full bg-white pb-1 pr-1'>
            <p className='text-tertiary text-[0.6rem]'>{card.m_rank}</p>
            <Suit suit={card.m_suit} className='h-2 w-2 overflow-visible' />
          </div>
        </>
      )}
    </motion.div>
  );
};
