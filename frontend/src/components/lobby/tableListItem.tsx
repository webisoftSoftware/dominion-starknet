import { useCallback, useState } from 'react';
import { Button } from '../button';
import { Modal } from '../modal';
import { TableDetails } from './tableDetails';
import Chip from '../../assets/Chip.svg?react';
import { TableInfo } from '@frontend/types';
import { useNavigate } from '@tanstack/react-router';
import { BuyChipsModal } from './buyChipsModal';
import {
  useBalanceChips,
  useDojo,
} from '@frontend/chains/starknet/DojoWrapper';
import { useChainClient, useWallet } from '@frontend/providers/ChainsProvider/utils';

export const TableListItem = ({ table, index }: { table: TableInfo; index: number; }) => {
  const [showModal, setShowModal] = useState<'not connected' | 'insufficient' | 'buy' | null>(null);
  const {setCurrentTable, account} = useDojo();
  const wallet = useWallet();
  const atTable = wallet ? table.m_players
    .find(player => player === wallet.address) !== undefined
    : false;
  const balance = Number(useBalanceChips(wallet?.address ?? "0x0"));
  const chainClient = useChainClient();

  const navigate = useNavigate();

  const handleView = useCallback(() => {
    if (!wallet) {
      setShowModal('not connected');
      return;
    }

    if (balance < table.m_minBuyIn) {
      console.log(balance);
      setShowModal('insufficient');
      return;
    }

    if (account && chainClient?.getChainType() === "starknet") {
      setCurrentTable(table.m_id);
    }
    navigate({
      to: '/room/$roomId',
      params: { roomId: (table.m_id).toString() },
    });
  }, [wallet, balance, table.m_minBuyIn]);

  return (
    <div className='bg-secondary rounded-b-[2rem] rounded-t-2xl'>
      {/* Header */}
      <div className='flex h-16 items-center justify-between px-6 py-4'>
        <div className='flex items-center gap-6'>
          <p className='text-sm'>{index + 1}</p>
          <h1 className='text-sm font-medium'>{table.m_name}</h1>
        </div>
        {table.m_players.length === table.m_maxPlayers && (
          <div className='bg-primary border-tertiary text-text-disabled rounded-full border-[1px] px-4 py-2 text-sm font-medium'>
            Full
          </div>
        )}
      </div>
      {/* Divider */}
      <div className='bg-primary h-1 w-full' />
      {/* Table Details */}
      <div className='flex flex-col gap-2 px-6 py-4'>
        <TableDetails table={table} />
      </div>
      {/* Action */}
      <div className='p-6'>
        {table.m_players.length === table.m_maxPlayers ? (
          <Button variant='secondary' fullWidth>
            Spectate Table
          </Button>
        ) : wallet && wallet.status === "connected" && atTable ? (
          <Button variant='primary' fullWidth onClick={handleView}>
            Back to Table
          </Button>
        ) : wallet && wallet.status === "connected" && !atTable ? (
          <Button variant='primary' fullWidth onClick={handleView}>
            Enter Table
          </Button>
        ) : (
          <Button variant='primary' fullWidth disabled={true}>
            Not Connected
          </Button>
        )}
      </div>
      {/* Insufficient Balance */}
      <Modal
        title={'Insufficient Chips'}
        visible={showModal === 'insufficient'}
        onClose={() => setShowModal(null)}
        content={
          <p className='text-text-secondary text-center'>
            Uh oh! You don&apos;t have enough{' '}
            <span>
              <Chip className='mr-1 inline w-4' />
              chips
            </span>{' '}
            to play. Buy{' '}
            <span>
              <Chip className='mr-1 inline w-4' />
              chips
            </span>{' '}
            to participate in Dominion Poker!
          </p>
        }
        confirm={{
          title: 'Buy Chips',
          action: () => setShowModal('buy'),
        }}
      />
      <BuyChipsModal balance={balance} visible={showModal === 'buy'} onClose={() => setShowModal(null)} />
    </div>
  );
};
