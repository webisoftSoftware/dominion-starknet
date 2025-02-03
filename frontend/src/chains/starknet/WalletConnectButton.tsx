import { useWallet } from '@frontend/providers/ChainsProvider';
import { useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';

// Toast component
const Toast = ({ message }: { message: string }) => (
  <motion.div
    initial={{ opacity: 0, y: 10 }}
    animate={{ opacity: 1, y: 0 }}
    exit={{ opacity: 0 }}
    className="fixed left-1/2 top-20 z-50 -translate-x-1/2 rounded-lg bg-tertiary px-4 py-2 text-sm text-text-primary shadow-lg"
  >
    {message}
  </motion.div>
);

export function WalletConnectButton() {
  const wallet = useWallet();
  const [showToast, setShowToast] = useState(false);

  const handleCopyAddress = async () => {
    if (!wallet?.address) return;

    try {
      await navigator.clipboard.writeText(wallet.address);
      setShowToast(true);
      setTimeout(() => setShowToast(false), 1000);
    } catch (err) {
      console.error('Failed to copy address:', err);
    }
  };

  const WalletIcon = () => (
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
      <path strokeLinecap="round" strokeLinejoin="round" d="M21 12a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 12m18 0v6a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 9" />
    </svg>
  );

  if (wallet && wallet.status === "connected") {
    return (
      <div className="flex flex-grow justify-end items-center">
        <button className="text-text-primary text-sm hidden md-mobile:inline"
        onClick={() => handleCopyAddress()}>
          {`${wallet.address?.slice(0,6)}...${wallet.address?.slice(-4)}`}
        </button>
        <button
          onClick={() => wallet?.disconnect()}
          className="text-text-primary p-2 rounded-full hover:bg-opacity-80"
        >
          <WalletIcon />
        </button>

        <AnimatePresence>
          {showToast && <Toast message="Address copied to clipboard!" />}
        </AnimatePresence>
      </div>
    );
  }

  return (
      <div className="flex justify-end items-center">
        <button
          onClick={() => wallet?.connect()}
          className="gap-2 text-text-primary rounded-full hover:bg-opacity-80 disabled:opacity-50 inline-flex align-middle items-center justify-between px-2 py-1 text-sm"
        >
          <span className={"p-2 hidden w-0 md-mobile:w-full md-mobile:inline"}>Connect Wallet</span>
          <WalletIcon />
        </button>
        <AnimatePresence>
          {showToast && <Toast message="Address copied to clipboard!" />}
        </AnimatePresence>
      </div>
  );
}
