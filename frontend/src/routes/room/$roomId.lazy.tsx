import { createLazyFileRoute } from '@tanstack/react-router'
import { User } from '@frontend/types'
import { Player } from '@frontend/components/table/player'
import { AnimatedRoute } from '@frontend/components/routes/animatedRoute'

import { useChainClient, useWallet } from '@frontend/providers/ChainsProvider/utils';
import { PokerRoomDojo } from '@frontend/components/PokerRoomDojo'

export const Route = createLazyFileRoute('/room/$roomId')({
  component: RouteComponent,
})

export const PlayerRow = ({ players = [] }: { players: User[] }) => {
  const wallet = useWallet();

  return (
    <>
      <Player player={players[0]} isMe={players[0]?.m_address === wallet?.address} />
      <div className="col-span-1" />
      <Player
        player={players[1]}
        isMe={players[1]?.m_address === wallet?.address}
        reverse
      />
    </>
  )
}

function RouteComponent() {
  const { roomId } = Route.useParams();
  const client = useChainClient();
  const wallet = useWallet();

  if (!wallet || wallet.status !== "connected") {
    return (
      <AnimatedRoute className='flex h-dvh max-h-dvh flex-col'>
        <div className="text-text-primary bg-secondary flex flex-col items-center justify-center h-full">
          Please connect your wallet to access poker tables
        </div>
      </AnimatedRoute>
    );
  }

  return (
    <AnimatedRoute className='relative flex bg-secondary h-dvh max-h-dvh flex-col'>
      {client?.getChainId() === 'starknet' ? (
          <PokerRoomDojo roomId={Number(roomId)} />
      ) : (
        <div>Cannot display table, we are not on Starknet!</div>
      )}
    </AnimatedRoute>
  );
}
