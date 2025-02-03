import React, { useEffect, useState } from 'react';
import { ControllerConnector } from '@cartridge/connector';
import { useAccount, useBalance, useConnect, useDisconnect } from '@starknet-react/core';
import { ControllerContext } from '@frontend/chains/starknet/hooks';

export function ControllerProvider({ children }: { children: React.ReactNode }) {
  const { address } = useAccount();
  const { connect: starknetConnect, connectors } = useConnect();
  const { disconnect: starknetDisconnect } = useDisconnect();
  const balance = useBalance({ address: address });

  const [status, setStatus] = useState<'connected' | 'connecting' | 'disconnected'>('disconnected');
  const [username, setUsername] = useState<string>();
  const [controllerInstance, setControllerInstance] = useState<ControllerConnector | null>(null);

  // Set controller instance when connector is available
  useEffect(() => {
    if (connectors[0] && connectors[0] instanceof ControllerConnector) {
      setControllerInstance(connectors[0] as ControllerConnector);
    }
  }, [connectors]);

  // Update username when address changes
  useEffect(() => {
    const fetchUsername = async () => {
      if (controllerInstance && address) {
        try {
          const name = await controllerInstance.username();
          setUsername(name || undefined);
          setStatus('connected');
        } catch (error) {
          console.error('Failed to fetch username:', error);
          setStatus('disconnected');
        }
      }
    };

    fetchUsername();
  }, [address, controllerInstance]);

  const connect = async () => {
    if (!controllerInstance) return;

    try {
      setStatus('connecting');
      await controllerInstance.connect();
      starknetConnect( {connector: controllerInstance } );
      const name = await controllerInstance.username();
      setUsername(name || undefined);
      setStatus('connected');
      console.log("[Controller]: Controller wallet status:", status);
    } catch (error) {
      console.error('Failed to connect:', error);
      setStatus('disconnected');
    }
  };

  const disconnect = async () => {
    if (!controllerInstance) return;

    try {
      await controllerInstance.disconnect();
      starknetDisconnect();
      setUsername(undefined);
      setStatus('disconnected');
      console.log("[Controller]: Controller wallet status:", status);
    } catch (error) {
      console.error('Failed to disconnect:', error);
    }
  };

  return (
    <ControllerContext.Provider
      value={{
        address,
        username,
        balance: Number(balance.data?.value),
        status,
        connect,
        disconnect
      }}
    >
      {children}
    </ControllerContext.Provider>
  );
}
