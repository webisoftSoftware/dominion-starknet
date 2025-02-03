import { Button } from '@frontend/components/button';
import { User } from '@frontend/types';
import InfoCircle from '../../../assets/icons/InfoCircle.svg?react';
import MessageNotification from '../../../assets/icons/MessageNotification.svg?react';
import ChevronLeft from '../../../assets/icons/ChevronLeft.svg?react';
import { useNavigate } from '@tanstack/react-router';
import React, { useCallback, useState } from 'react';
import { ConfirmLeaveModal } from '../confirmLeaveModal';
import { ThemeDropdown } from './ThemeDropdown';
import Palette from '../../../assets/icons/Palette.svg?react';

interface GameHeaderProps {
  room: number;
  user: {player: User | undefined, atTable: boolean};
  theme: string;
  setTheme: (theme: string) => void;
}

export const GameHeader = ({ room, user, theme, setTheme }: GameHeaderProps) => {
  const [confirmLeave, setConfirmLeave] = useState(false);
  const [isHovered, setHover] = useState(false);
  const [isThemeDropdownOpen, setIsThemeDropdownOpen] = useState(false);
  const navigate = useNavigate();

  const handleLeave = useCallback(() => {
    if (user.atTable) {
      setConfirmLeave(true);
      return;
    }
    navigate({ to: '/' })
      .then(_ => console.log("Navigating to /"),
        e => console.error(e));
  }, [navigate, user]);

  return (
    <div className='bg-secondary relative flex items-center justify-between p-3'>
      <Button variant='secondary' compact className='text-xs pl-2' onClick={handleLeave}>
        <ChevronLeft />
        Return to Lobby
      </Button>
      <div className='flex items-center gap-2'>
        <Button variant='secondary' compact className='p-2'>
          <InfoCircle />
        </Button>
        <Button
          variant='secondary'
          compact
          className='p-2'
          onMouseEnter={() => setHover(true)}
          onMouseLeave={() => setHover(false)}
          onClick={() => setIsThemeDropdownOpen(!isThemeDropdownOpen)}
        >
          {isHovered &&
            <div className={"text-text-primary text-xs flex h-full flex-col items-center justify-center"}>
            Select theme
          </div>}
          <Palette />
        </Button>
        <Button variant='secondary' compact className='p-2'>
          <MessageNotification />
        </Button>
      </div>
      <ThemeDropdown
        isOpen={isThemeDropdownOpen}
        onClose={() => setIsThemeDropdownOpen(false)}
        onSelectTheme={setTheme}
        currentTheme={theme}
      />
      <ConfirmLeaveModal room={room} visible={confirmLeave} onClose={() => setConfirmLeave(false)} />
    </div>
  );
};
