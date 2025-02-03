import { Button } from '@frontend/components/button';
import { motion } from 'framer-motion';

import Plus from '../../../assets/icons/Plus.svg?react';
import Minus from '../../../assets/icons/Minus.svg?react';
import Chip from '../../../assets/Chip.svg?react';
import { User } from '@frontend/types';
import { useModel } from '@frontend/chains/starknet/DojoWrapper';
import React, { useState } from 'react';

export interface PlayerActionProps {
  room: number;
  player: User | undefined;
  theme: string;
}

export function PlayerAction({ room, player }: PlayerActionProps) {
  const playerModel = useModel([room, player?.m_address ?? '0x0'], 'ComponentPlayer');
  const [chipsToBeAdded, setChipsToBeAdded] = useState(0);
  const chipsRef = React.useRef(chipsToBeAdded);
  const intervalRef = React.useRef<NodeJS.Timer>();
  const [multiplier, setMultiplier] = useState(10);
  const [showMultiplierDropdown, setShowMultiplierDropdown] = useState(false);

  const multiplierOptions = [10, 20, 50, 100, 1000];

  // Update the ref whenever chipsToBeAdded changes
  React.useEffect(() => {
    chipsRef.current = chipsToBeAdded;
  }, [chipsToBeAdded]);

  console.log('[Action]: Player has', playerModel?.m_table_chips, 'chips');

  const incrementChips = () => {
    const currentChips = chipsRef.current;

    if (!playerModel || Number(playerModel.m_table_chips) === currentChips) {
      stopInterval();
      return;
    }

    if (!playerModel || Number(playerModel.m_table_chips) < currentChips + multiplier) {
      setChipsToBeAdded(Number(playerModel.m_table_chips));
      return;
    }

    setChipsToBeAdded(currentChips + multiplier);
  };

  const decrementChips = () => {
    const currentChips = chipsRef.current;
    if (currentChips === 0) {
      stopInterval();
      return;
    }

    if (currentChips - multiplier < 0) {
      setChipsToBeAdded(0);
      return;
    }

    setChipsToBeAdded(currentChips - multiplier);
  };

  const exponentialIncrementChips = () => {
    if (!playerModel || Number(playerModel.m_table_chips) < chipsRef.current + multiplier) {
      return;
    }
    intervalRef.current = setInterval(incrementChips, 100);
  };

  const exponentialDecrementChips = () => {
    if (chipsRef.current - multiplier < 0) {
      return;
    }
    intervalRef.current = setInterval(decrementChips, 100);
  };

  const stopInterval = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = undefined;
    }
  };

  const useClickOutside = (ref: React.RefObject<HTMLElement>, handler: () => void) => {
    React.useEffect(() => {
      const handleClickOutside = (event: MouseEvent) => {
        if (ref.current && !ref.current.contains(event.target as Node)) {
          handler();
        }
      };

      document.addEventListener('mousedown', handleClickOutside);
      return () => {
        document.removeEventListener('mousedown', handleClickOutside);
      };
    }, [ref, handler]);
  };

  const dropdownRef = React.useRef<HTMLDivElement>(null);
  useClickOutside(dropdownRef, () => setShowMultiplierDropdown(false));

  return (
    <motion.div
      className='flex flex-col gap-4'
      exit={{ height: 0, transition: { delay: 0.1, type: 'spring', damping: 30, stiffness: 200 } }}
    >
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        exit={{ opacity: 0, y: 20 }}
        animate={{
          opacity: 1,
          y: 0,
          transition: { delay: 0.1, type: 'spring', damping: 30, stiffness: 200 },
        }}
        className='flex items-center px-1'
      >
        <div className='flex items-center gap-1'>
          <Button
            variant='secondary'
            compact
            className='h-8 w-8 p-0'
            onMouseUp={stopInterval}
            onMouseDown={exponentialDecrementChips}
            onMouseLeave={stopInterval}
            onTouchStart={exponentialDecrementChips}
            onTouchEnd={stopInterval}
            onTouchCancel={stopInterval}
            onTouchMove={stopInterval}
            onClick={decrementChips}
          >
            <Minus className='w-4' />
          </Button>
          <Button
            variant='secondary'
            compact
            className='h-8 w-8 p-0'
            onMouseUp={stopInterval}
            onMouseDown={exponentialIncrementChips}
            onMouseLeave={stopInterval}
            onTouchStart={exponentialIncrementChips}
            onTouchEnd={stopInterval}
            onTouchCancel={stopInterval}
            onTouchMove={stopInterval}
            onClick={incrementChips}
          >
            <Plus className='w-4' />
          </Button>
        </div>
        <div className="relative" ref={dropdownRef}>
          <Button
            variant='secondary'
            compact
            className='m-auto ml-2 flex items-center gap-1 px-2'
            onClick={() => setShowMultiplierDropdown(!showMultiplierDropdown)}
          >
            <Chip className='w-4' />
            <span className='text-text-primary text-xs font-medium'>+ {multiplier}</span>
          </Button>

          {showMultiplierDropdown && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              className="absolute w-[100px] bottom-full mb-1 z-50 bg-primary border border-accent rounded-md shadow-lg"
            >
              {multiplierOptions.map((value) => (
                <button
                  key={value}
                  className="w-full px-4 py-2 text-left hover:bg-accent/20 text-text-primary text-sm"
                  onClick={() => {
                    setMultiplier(value);
                    setShowMultiplierDropdown(false);
                  }}
                >
                  + {value}
                </button>
              ))}
            </motion.div>
          )}
        </div>
        <Button className='ml-auto mr-0 p-3 max-w-[40%] disabled:opacity-40' compact>
          <p className='text-text-primary text-xs font-medium'>
            {playerModel?.m_table_chips === chipsToBeAdded ? `All In (${chipsToBeAdded})` : `Raise ${chipsToBeAdded}`}
          </p>
        </Button>
      </motion.div>

      {playerModel?.m_state.toString() !== 'Folded' && (
        <motion.div
          initial={{ y: '100%' }}
          exit={{ y: '100%' }}
          animate={{
            y: 0,
            transition: { delay: 0.2, type: 'spring', damping: 25, stiffness: 200 },
          }}
          className='bg-primary border-accent border-b-primary z-0 flex items-center gap-2 rounded-t-[2rem] border-[1px] p-3 pb-2'
        >
          <Button className='bg-error shadow-inner-skeu h-xs:py-3 font-medium' fullWidth>
            Fold
          </Button>
          <Button variant='secondary' fullWidth className='bg-special shadow-inner-skeu h-xs:py-3 font-medium'>
            Check
          </Button>
        </motion.div>
      )}
    </motion.div>
  );
}
