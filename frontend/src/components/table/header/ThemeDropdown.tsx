import React from 'react';
import { ThemeSelector } from '@frontend/games/poker/ThemeSelector';

interface ThemeDropdownProps {
  currentTheme: string;
  onSelectTheme: (theme: string) => void;
  isOpen: boolean;
  onClose: () => void;
}

export function ThemeDropdown({ currentTheme, onSelectTheme, isOpen, onClose }: ThemeDropdownProps) {
  if (!isOpen) return null;

  return (
    <div className="absolute right-2 sm:right-20 top-14 z-50 w-[calc(100vw-1rem)] sm:w-[400px] rounded-lg bg-secondary p-4 shadow-lg">
      <ThemeSelector
        onSelectTheme={(theme) => {
          onSelectTheme(theme);
          onClose();
        }}
        selectedTheme={currentTheme}
      />
    </div>
  );
}
