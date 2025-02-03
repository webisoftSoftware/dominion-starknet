import { Button } from '../button';
import { Modal } from '../modal';
import { TableDetails } from './tableDetails';
import Chip from '../../assets/Chip.svg?react';
import Minus from '../../assets/icons/Minus.svg?react';
import Plus from '../../assets/icons/Plus.svg?react';
import { formatChips } from '@frontend/utils/formatChips';
import type { TableInfo, User } from '@frontend/types';
import { useCallback, useState } from 'react';
import { useDojo } from '@frontend/chains/starknet/DojoWrapper';
import { useChainClient } from '@frontend/providers/ChainsProvider/utils';
import {
  ACTIONS_CONTRACT_ADDRESS
} from '@frontend/games/poker/client/starknet/StarknetPokerRoomClient';

type JoinTableModalProps = { table: TableInfo; user: User | undefined; visible: boolean; onClose: () => void };

export const JoinTableModel = ({ table, user, visible, onClose }: JoinTableModalProps) => {
  const [buyIn, setBuyIn] = useState(table.m_minBuyIn);
  const {account} = useDojo();
  const client = useChainClient();
  const [transactionInProgress, setTransactionInProgress] = useState(false);

  const handleBuyIn = useCallback(() => {
      console.log(`[Join]: Player requested to join table ${table.m_id}`)
      if (user && buyIn > 0)
        if (client?.getChainType() === "starknet" && account) {
          setTransactionInProgress(true);
          account.execute({
            contractAddress: ACTIONS_CONTRACT_ADDRESS,
            entrypoint: "join_table",
            calldata: [table.m_id, buyIn]
          }).then(
            async res => {
              await account.waitForTransaction(res.transaction_hash);
              setTransactionInProgress(false);
              console.log(`[Join]: Player ${user.m_address} has joined the table ${table.m_id}`)
            },
                (e) => console.error(e)
          );
        }
      onClose();
    },
    [account, buyIn, table.m_id, user],
  );

  return (
    <Modal
      title={'Join Table?'}
      visible={visible || transactionInProgress}
      onClose={!transactionInProgress ? onClose : () => { console.log("[Join]: Waiting for " +
        "transaction to complete..."); }}
      hideCancel
      showX
      content={
        <div className='flex w-full flex-col gap-4 max-w-[640px]'>
          <div className='bg-tertiary flex w-full flex-col items-center gap-6 rounded-[2rem] p-4'>
            <p className='text-text-tertiary text-xs font-medium uppercase'>Buy-In Amount</p>
            <div className='flex w-full flex-col items-center justify-center'>
              <div className='flex w-full items-center justify-between gap-2'>
                <Button
                  onClick={() => setBuyIn((prev) => Math.max(table.m_minBuyIn, prev - 50))}
                  compact
                  variant='primary'
                  className='border-special text-accent flex h-8 w-8 items-center justify-center border-[1px] bg-transparent p-0'
                >
                  <Minus />
                </Button>
                <span className='flex flex-1 items-center justify-center gap-2'>
                  <Chip />
                  <h1 className='text-2xl font-medium'>{formatChips(buyIn)} Chips</h1>
                </span>
                <Button
                  onClick={() => setBuyIn((prev) => Math.min(table.m_maxBuyIn, prev + 50))}
                  compact
                  className='border-special text-accent flex h-8 w-8 items-center justify-center border-[1px] bg-transparent p-0'
                  variant='primary'
                >
                  <Plus />
                </Button>
              </div>

              <div className='text-text-tertiary flex items-center justify-center gap-1 text-xs'>
                Balance:
                <Chip className='w-2' />
                {formatChips(user?.m_balance ?? 0)} Chips
              </div>
            </div>

            <div className='flex w-full gap-2 text-xs'>
              <Button
                compact
                onClick={() => setBuyIn(table.m_minBuyIn)}
                variant='primary'
                fullWidth
                className='text-text-primary px-3'
              >
                <p className='text-sm font-medium'>Min</p>
              </Button>

              <Button
                compact
                onClick={() => setBuyIn(table.m_maxBuyIn)}
                variant='primary'
                fullWidth
                className='text-text-primary px-3'
              >
                <p className='text-sm font-medium'>Max</p>
              </Button>
            </div>
          </div>

          <div className='border-t-tertiary border-primary mt-4 flex flex-col gap-2 border-[1px] p-3'>
            <p className='text-text-tertiary text-xs font-medium uppercase'>Lobby Details</p>
            <TableDetails table={table} />
          </div>
        </div>
      }
      confirm={{
        title: 'Buy In',
        action: handleBuyIn,
        disabled: buyIn > (user?.m_balance ?? 0) || buyIn < table.m_minBuyIn || buyIn > table.m_maxBuyIn ||
          transactionInProgress,
      }}
    />
  );
};
