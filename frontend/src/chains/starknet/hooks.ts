import React, { useContext } from 'react';
import { ControllerConnector } from '@cartridge/connector';

interface ControllerContextType {
  connector?: ControllerConnector,
  address?: string,
  username?: string,
  balance?: number,
  status: "connected" | "connecting" | "disconnected",
  connect: () => void,
  disconnect: () => void,
}

export const ControllerContext = React.createContext<ControllerContextType | null>(null);

export function useController() {
  const context = useContext(ControllerContext);
  if (!context) {
    throw new Error('useController must be used within a ControllerProvider');
  }
  return context;
}

export function useUsername(): Promise<string> | undefined {
  const context = useContext(ControllerContext);
  if (!context) {
    throw new Error('useController must be used within a ControllerProvider');
  }

  return context.connector?.username();
}
