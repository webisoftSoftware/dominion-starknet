import { useEffect, useState } from 'react';
// import { AnimatePresence, motion } from 'framer-motion';

import Logo from '../assets/Logo.svg?react';
import Chip from '../assets/Chip.svg?react';
// import LinkExternal from '../assets/icons/LinkExternal.svg?react';
import { formatChips } from '@frontend/utils/formatChips';
// import { cn } from '@frontend/utils/cn';
import { BuyChipsModal } from './lobby/buyChipsModal';
import {WalletAccount} from "@frontend/chains/types";
import { WalletConnectButton } from '@frontend/chains/starknet/WalletConnectButton';
import { useModel } from '@frontend/chains/starknet/DojoWrapper';

// const HeaderLink = ({ text, href, external }: { text: string; href: string; external?: boolean }) => {
//   return (
//     <a
//       className='active:bg-secondary transition-colors flex w-full px-2 py-2 text-sm font-medium duration-100'
//       href={href}
//       target={external ? '_blank' : '_self'}
//       rel='noreferrer'
//     >
//       {text}
//       {external && <LinkExternal />}
//     </a>
//   );
// };

export const Header = ({ user }: { user: WalletAccount | null }) => {
  // const [showDropdown, setShowDropdown] = useState(false);
  const [showBuyChipsModal, setShowBuyChipsModal] = useState(false);
  const [balance, setBalance] = useState(0);
  const playerModel = useModel([0, user?.address ?? "0x0"], "ComponentPlayer");

  useEffect(() => {
    console.log(`Total chips for player ${user?.address} = ${playerModel?.m_total_chips}`);
    setBalance(Number(playerModel?.m_total_chips ?? 0));
  }, [user, playerModel]);

  return (
    <>
      <div className='bg-secondary relative flex h-16 items-center justify-between'>
        <div className='p-3 flex items-center justify-center'>
          <Logo className='h-10 w-10' />
        </div>
        <div className='border-secondary border-x-tertiary flex w-full h-full gap-2 flex-1 items-center justify-between border-[1px] px-2'>
          <div className='flex items-center gap-2'>
            <div className='flex flex-col items-center justify-center mx-2'>
              <h1 className='text-text-primary text-sm'>Balance</h1>
              <div className='flex items-center justify-center gap-1'>
                <Chip className='w-5' />
                <span className='text-text-disabled text-sm'>{formatChips(balance)}</span>
                <span className={"text-text-disabled text-sm hidden lg-mobile:inline"}>Chips</span>
              </div>
            </div>
            <button
              onClick={() => setShowBuyChipsModal(true)}
              className='text-text-primary lg-mobile:bg-tertiary items-center gap-1 justify-items-center rounded-full flex px-2 py-0 lg-mobile::px-10 lg-mobile:py-2 text-sm font-medium'
            >
              <span className={"text text-sm opacity-0 w-0 lg-mobile:opacity-100 lg-mobile:w-full"}>Get More</span>
              <span className='relative h-4 w-4'>
                <Chip className='absolute -top-0.5 -left-1 w-4 opacity-75' />
                <Chip className='absolute left-1 top-0.5 w-4' />
              </span>
            </button>
          </div>
          <WalletConnectButton />
        </div>
        {/*<div className='relative z-0 flex h-full items-center justify-center p-3'>*/}
        {/*  <span*/}
        {/*    className={cn(*/}
        {/*      'bg-tertiary absolute inset-0 -z-10 transition-transform duration-100',*/}
        {/*      showDropdown ? 'scale-100 rounded-none' : 'scale-0 rounded-full',*/}
        {/*    )}*/}
        {/*  />*/}
        {/*  <button*/}
        {/*    onClick={() => setShowDropdown((prev) => !prev)}*/}
        {/*    className='bg-tertiary flex h-9 w-9 flex-col items-center justify-center gap-1 rounded-full'*/}
        {/*  >*/}
        {/*    <span className='bg-text-primary h-[1px] w-4 rounded-full' />*/}
        {/*    <span className='bg-text-primary h-[1px] w-4 rounded-full' />*/}
        {/*  </button>*/}
        {/*</div>*/}
        {/*<AnimatePresence>*/}
        {/*  {showDropdown && (*/}
        {/*    <motion.div className='absolute top-full z-0 h-dvh w-full'>*/}
        {/*      <motion.div*/}
        {/*        initial={{ height: 0 }}*/}
        {/*        animate={{ height: 'auto' }}*/}
        {/*        exit={{ height: 0, transition: { duration: 0.1 } }}*/}
        {/*        className='bg-tertiary text-text-secondary top-full w-full'*/}
        {/*      >*/}
        {/*      </motion.div>*/}
        {/*      <motion.div*/}
        {/*        initial={{ opacity: 0 }}*/}
        {/*        exit={{ opacity: 0 }}*/}
        {/*        animate={{ opacity: 0.5 }}*/}
        {/*        className='h-full w-full bg-black'*/}
        {/*        onClick={() => setShowDropdown(false)}*/}
        {/*      />*/}
        {/*    </motion.div>*/}
        {/*  )}*/}
        {/*</AnimatePresence>*/}
      </div>

      {user && (
        <BuyChipsModal
          visible={showBuyChipsModal}
          onClose={() => setShowBuyChipsModal(false)}
          balance={balance}
          setBalance={setBalance}
        />
      )}
    </>
  );
};
