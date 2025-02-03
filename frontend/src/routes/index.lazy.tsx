import { createLazyFileRoute } from '@tanstack/react-router';
import { Header } from '@frontend/components/header';
import { AnimatedRoute } from '@frontend/components/routes/animatedRoute';

import { useChainClient, useWallet } from '@frontend/providers/ChainsProvider/utils';
import { MainMenuDojo } from '@frontend/components/table/MainMenuDojo';
import React from 'react';

export const Route = createLazyFileRoute('/')({
  component: Index,
});

function Index() {
  const client = useChainClient();
  const wallet = useWallet();

  return (
    <AnimatedRoute
      direction={{ enter: 'right', exit: 'left' }}
      className='flex h-dvh max-h-dvh flex-col'
    >
      <Header user={wallet} />
      <div className='text-text-primary flex bg-secondary flex-1 flex-col overflow-y-scroll p-3'>
        <div className='border-secondary border-b-primary border-[2px] mb-3 py-6'>
          <h1 className='text-xl font-medium'>Poker Tables</h1>
        </div>
        {client?.getChainType() === 'starknet' ? (
          <MainMenuDojo />
        ) : (
          <div className='flex flex-col gap-4 py-6'>
            <p>Target chain is not Starknet!</p>
          </div>
        )}
      </div>
    </AnimatedRoute>
  );
}
