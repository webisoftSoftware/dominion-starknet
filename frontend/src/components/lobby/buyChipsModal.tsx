import { Button } from '../button';
import { Modal } from '../modal';
import Chip from '../../assets/Chip.svg?react';
import Ethereum from '../../assets/Ethereum.svg?react';
import Minus from '../../assets/icons/Minus.svg?react';
import Plus from '../../assets/icons/Plus.svg?react';
import { formatChips } from '@frontend/utils/formatChips';
import React, { useCallback, useState } from 'react';
import { useChainClient, useWallet } from '@frontend/providers/ChainsProvider/utils';
import { useDojo } from '@frontend/chains/starknet/DojoWrapper';
import { CASHIER_CONTRACT_ADDRESS } from '@frontend/games/poker/client/starknet/StarknetPokerRoomClient';
import { cairo } from 'starknet';

const CHIP_TO_ETH = 0.001 / 1000; // 1000 Chips per 0.001 ETH
const ETH_ERC_20_ADDRESS = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
const ETH_TO_WEI = 1000000000000000000;

interface BuyChipsModalProps {
  balance: number;
  visible: boolean;
  onClose: () => void;
}

export const BuyChipsModal = ({ balance, visible, onClose }: BuyChipsModalProps) => {
  const [amount, setAmount] = useState(1000);
  const [isTransacting, setIsTransacting] = useState(false);
  const chainClient = useChainClient();
  const { account } = useDojo();
  const wallet = useWallet();

  const handleBuyChips = useCallback(async () => {
    if (!wallet || wallet.status === 'disconnected') {
      console.error('Not Connected');
      return;
    }
    console.log(`[Buy]: Purchasing ${amount} chips, Balance: ${balance}`);
    if (chainClient && chainClient.getChainType() === 'starknet') {
      if (account) {
        const eth_amount = ETH_TO_WEI * amount * CHIP_TO_ETH;

        // First approve ETH amount for cashier.
        setIsTransacting(true);
        await account.execute({
          contractAddress: ETH_ERC_20_ADDRESS,
          calldata: [CASHIER_CONTRACT_ADDRESS, cairo.uint256((eth_amount))],
          entrypoint: 'approve',
        }).then(async res => {
            await account.waitForTransaction(res.transaction_hash);
            account.execute({
              contractAddress: CASHIER_CONTRACT_ADDRESS,
              calldata: [cairo.uint256((eth_amount))],
              entrypoint: 'deposit_erc20',
            }).then(
              async (res) => {
                await account.waitForTransaction(res.transaction_hash);
                console.log(`[Buy]: Deposited ${amount} into account ${account}\nTransaction: ${res.transaction_hash}`);
                setIsTransacting(false);
              },
              (e) => {
                console.error(`[Buy]: Error approving chips: ${e}`)
                setIsTransacting(false);
              },
            );
            console.log(`[Buy]: Approved ${amount} chips to spend for cashier contract\nTransaction: ${res.transaction_hash}`);
          },
          e => {
            console.error(e);
          });
      }
    }
    onClose();
  }, [wallet, amount, account, balance]);

  return (
    <Modal
      title={'Buy Chips'}
      visible={visible}
      onClose={!isTransacting ? onClose : () => console.log("[Buy]: Waiting for transaction " +
        "to be complete...")}
      hideCancel
      showX
      content={
        <div className='flex w-full flex-col gap-4'>
          <div className='bg-tertiary flex w-full flex-col items-center gap-6 rounded-3xl p-4'>
            <div className='text-text-tertiary flex items-center justify-center gap-1 text-xs font-medium'>
              <Chip className='w-2' />
              5,000 per <Ethereum className='w-2' /> 0.005
            </div>
            <div className='flex w-full items-center justify-between gap-2'>
              <Button
                onClick={() => setAmount((prev) => Math.max(0, prev - 50))}
                compact
                variant='primary'
                className='border-special text-accent flex h-8 w-8 items-center justify-center border-[1px] bg-transparent p-0'
              >
                <Minus />
              </Button>

              <div className='flex flex-col items-center justify-center'>
                <span className='flex items-center gap-2'>
                  <Chip />
                  <h1 className='text-3xl font-medium'>{formatChips(amount)}</h1>
                </span>
                <span className='flex items-center gap-2'>
                  <Ethereum />
                  <h1 className='text-text-secondary text-lg'>{(amount * CHIP_TO_ETH).toFixed(4)} ETH</h1>
                </span>
              </div>
              <Button
                onClick={() => setAmount((prev) => prev + 50)}
                compact
                className='border-special text-accent flex h-8 w-8 items-center justify-center border-[1px] bg-transparent p-0'
                variant='primary'
              >
                <Plus />
              </Button>
            </div>
          </div>
          <div className='flex flex-col gap-2'>
            <h2 className='text-text-secondary text-center text-sm font-medium'>Current Balance</h2>
            <div className='flex gap-2'>
              <div className='bg-tertiary flex flex-1 items-center justify-center gap-1 rounded-full p-2'>
                <Ethereum className='w-4' />
                <p className='text-sm font-medium'>{(balance * CHIP_TO_ETH).toFixed(4)} ETH</p>
              </div>
              <div className='bg-tertiary flex flex-1 items-center justify-center gap-1 rounded-full p-2'>
                <Chip className='w-4' />
                <p className='text-sm font-medium'>{formatChips(balance)}</p>
              </div>
            </div>
          </div>
        </div>
      }
      confirm={{
        title: isTransacting ? 'Processing...' :
          wallet && wallet.status === 'connected' ? 'Purchase' : 'Not Connected',
        action: handleBuyChips,
        disabled: isTransacting || !wallet || wallet.status !== 'connected',
      }}
    />
  );
};
