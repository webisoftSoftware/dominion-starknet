import { motion } from 'framer-motion';
import { CardContainer } from '../cardContainer';
import { User } from '@frontend/types';

export const PlayerHand = ({ user, currentPlayerAddress }: { user: User; currentPlayerAddress: string }) => {
  return (
    <motion.div layout className='absolute -z-10 flex w-full justify-center'>
      <motion.div
        animate={{ y: currentPlayerAddress === user.m_address ? '-40%' : '-70%' }}
        transition={{
          type: 'spring',
          damping: 30,
          stiffness: 200,
          delay: 0.1,
        }}
        className='bg-secondary h-xs:gap-3 h-xs:p-3 h-xs:h-40 flex h-28 gap-2 rounded-2xl p-2'
      >
        <CardContainer key='user-card-0' card={user.m_cards[0]} />
        <CardContainer key='user-card-1' card={user.m_cards[1]} />
      </motion.div>
    </motion.div>
  );
};
