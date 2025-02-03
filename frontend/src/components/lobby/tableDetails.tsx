import { TableInfo } from '@frontend/types';
import Chip from '../../assets/Chip.svg?react';
import Users from '../../assets/icons/Users.svg?react';
import { formatChips } from '@frontend/utils/formatChips';

export const TableDetails = ({ table }: { table: TableInfo }) => {
  if (!table) return;

  return (
    <>
      <div className='flex justify-between'>
        <h2>Min | Max Buy-In</h2>
        <span className='flex items-center gap-2'>
          <Chip />
          <p className='text-sm font-medium'>
            {formatChips(table.m_minBuyIn)} <span className='text-text-disabled/50'>|</span> {formatChips(table.m_maxBuyIn)}
          </p>
        </span>
      </div>
      <div className='flex justify-between'>
        <h2>Small | Big Blind</h2>
        <span className='flex items-center gap-2'>
          <Chip />
          <p className='text-sm font-medium'>
            {formatChips(table.m_smallBlind)} <span className='text-text-disabled/50'>|</span>{' '}
            {formatChips(table.m_bigBlind)}
          </p>
        </span>
      </div>
      <div className='flex justify-between'>
        <h2>Players</h2>
        <span className='flex items-center gap-2'>
          <Users />
          <p className='text-sm font-medium'>
            {table.m_players.length}/{table.m_maxPlayers}
          </p>
        </span>
      </div>
    </>
  );
};
