import React, { type SVGProps } from 'react';

export type RoomListItem = {
  id: number;
  currency: string;
  avgPot: number;
  tableName: string;
  totalPlayers: number;
  maxPlayers: number;
  stakes: number;
  roomName: string;
  tableIcon?: React.FC<SVGProps<SVGSVGElement> & { title?: string }>;
  game: string;
  chainInfo: any;
};
