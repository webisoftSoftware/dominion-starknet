import React from 'react';

interface ChainsConnectorProps {
  children: React.ReactNode;
}

const ChainsConnectors = ({ children }: ChainsConnectorProps) => {
  // TODO: Add Argent/Starknet wallet connector provider here
  return <>{children}</>;
};

export default ChainsConnectors;
