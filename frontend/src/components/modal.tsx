import { AnimatePresence, motion } from 'framer-motion';
import { Button, ButtonVariant } from './button';
import { cn } from '@frontend/utils/cn';
import Close from '../assets/icons/Close.svg?react';

type Action = {
  title: string;
  action: () => void;
  disabled?: boolean;
  type?: ButtonVariant;
};

type ModalProps = {
  visible: boolean;
  onClose: () => void;
  title: string;
  content: React.ReactNode;
  confirm?: Action;
  secondaryActions?: Action[];
  cancelText?: string;
  hideCancel?: boolean;
  showX?: boolean;
};
export const Modal = ({
  visible,
  title,
  content,
  onClose,
  hideCancel,
  confirm,
  secondaryActions,
  showX,
  cancelText,
}: ModalProps) => {
  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          key='modal-backdrop-blur'
          layoutId='modal-backdrop-blur'
          initial={{ backdropFilter: 'blur(0px)', backgroundColor: 'rgba(0, 0, 0, 0)' }}
          animate={{ backdropFilter: 'blur(5px)', backgroundColor: 'rgb(52 63 84 / 0.2)' }}
          exit={{ backdropFilter: 'blur(0px)', backgroundColor: 'rgba(0, 0, 0, 0)', transition: { delay: 0.1 } }}
          transition={{ duration: 0.1 }}
          className='text-text-primary fixed inset-0 z-[1000] flex m-auto flex-col items-end justify-center p-4'
        >
          <motion.div className='w-full flex-1' onClick={onClose} />
          <motion.div
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0, transition: { type: 'spring', stiffness: 200, damping: 20 } }}
            exit={{ opacity: 0, y: 50, transition: { duration: 0.1 } }}
            className='bg-primary flex w-full flex-col items-center m-auto jus gap-4 rounded-[2rem] p-6 max-w-[640px]'
          >
            <div className={cn('flex w-full items-center', showX ? 'justify-between' : 'justify-center')}>
              <h1 className='text-xl font-medium'>{title}</h1>
              {showX && (
                <Button onClick={onClose} compact variant='secondary' className='h-10 w-10 p-0'>
                  <Close />
                </Button>
              )}
            </div>
            <span className='bg-tertiary h-[1px] w-full' />
            {content}

            <div className='mt-4 flex w-full flex-col gap-4'>
              {confirm && (
                <Button disabled={confirm.disabled} variant='primary' fullWidth onClick={confirm.action}>
                  {confirm.title}
                </Button>
              )}
              {secondaryActions?.map((action, i) => (
                <Button
                  disabled={action.disabled}
                  variant={action?.type}
                  key={`modal-secondary-${title}-${i}`}
                  fullWidth
                  onClick={action.action}
                >
                  {action.title}
                </Button>
              ))}
              {!hideCancel && (
                <Button variant='secondary' fullWidth onClick={onClose}>
                  {cancelText || 'Cancel'}
                </Button>
              )}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
