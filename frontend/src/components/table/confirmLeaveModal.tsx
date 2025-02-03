import { useNavigate } from '@tanstack/react-router';
import { Modal } from '../modal';
import React, { useCallback } from 'react';
import { useDojo, useModel } from '@frontend/chains/starknet/DojoWrapper';
import { useWallet } from '@frontend/providers/ChainsProvider';
import {
  ACTIONS_CONTRACT_ADDRESS
} from '@frontend/games/poker/client/starknet/StarknetPokerRoomClient';
import { useChainClient } from '@frontend/providers/ChainsProvider/utils';
import { useUsername } from '@frontend/chains/starknet/hooks';
import { AnimatedRoute } from '@frontend/components/routes/animatedRoute';
import { useAccount } from '@starknet-react/core';

type ConfirmLeaveModalProps = {
  visible: boolean;
  room: number;
  onClose: () => void;
};

export const ConfirmLeaveModal = ({ visible, room, onClose }: ConfirmLeaveModalProps) => {
  const navigate = useNavigate();
  const wallet = useWallet();
  const { account } = useAccount();
  const chainCLient = useChainClient();
  const dojo = useDojo();
  const you = useModel([room, wallet?.address ?? "0x0"], "ComponentPlayer")

  const handleViewLobby = useCallback(() => {
    navigate({ to: '/' })
      .then(_ => console.log(`[View]: Player ${wallet} is viewing tables`));
  }, [navigate, wallet]);

  const handleExit = useCallback(() => {
    console.log(`[Leave]: Player requested to leave table ${room}`)
    if (you && dojo)
      if (chainCLient?.getChainType() === "starknet" && dojo.account) {
        dojo.account.execute({
          contractAddress: ACTIONS_CONTRACT_ADDRESS,
          entrypoint: "leave_table",
          calldata: [room]
        }).then(_ => {
            console.log(`[Leave]: Player ${wallet?.address} has left the table ${room}`);
            navigate({ to: '/' })
              .then(_ => console.log(`[Quit]: Player ${wallet} has left and automatically folded`),
                e => console.error(e));
          },
          (e) => console.error(e)
        );
      }
  }, [navigate, wallet]);

  if (!wallet || wallet.status !== "connected") {
    return (
      <AnimatedRoute className='flex h-dvh max-h-dvh flex-col'>
        <div className="text-text-primary bg-secondary flex flex-col items-center justify-center h-full">
          Please connect your wallet to access poker tables
        </div>
      </AnimatedRoute>
    );
  }

  console.log("Wallet status:", account);

  return (
    <Modal
      title={'Leaving?'}
      visible={visible}
      onClose={onClose}
      content={
        you?.m_state && you?.m_state.toString() === 'Active' ? (
          <p className='text-text-secondary text-center'>
            You&apos;re still in the game! You can return to the lobby and keep your seat, but the game will continue
            without you. You can also leave the game entirely by clicking on 'Exit Game'. Note that doing so will
            automatically fold you for the current round.
          </p>
        ) : (
          <p className='text-text-secondary text-center'>
            You&apos;re still in the game! You can return to the lobby and keep your seat. You can also leave the game
            entirely by clicking on <b>'Exit Game'</b>.
            <br></br>
            <br></br>
            <i>Note that if you do not leave and other players are waiting on you to be ready, you might get kicked.</i>
          </p>
        )
      }
      confirm={{
        title: 'View Lobby',
        action: handleViewLobby,
      }}
      secondaryActions={[
        {
          title: 'Exit Game',
          type: 'error',
          action: handleExit,
        },
      ]}
    />
  );
};
