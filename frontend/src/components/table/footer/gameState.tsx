import { PokerTable, User } from '@frontend/types';

const formatTableState = (state: string): string => {
  switch (state) {
    case "Shutdown": return "Game Ended";
    case "WaitingForPlayers": return "Waiting for Players...";
    default: return state;
  }
}

export const GameState = ({ table }: { table: PokerTable }) => {
  const playersReady: User[] = table.m_players.filter(player => player.m_state === "Ready");

  return (
    <div className='flex items-center gap-1 rounded-md bg-blue-500/20 max-w-[60%] px-2 py-2 text-xs text-blue-300'>
      {table.m_state === "WaitingForPlayers" && table.m_players.length > 0 ?
        `Not All players are ready... (${playersReady.length}/${table.m_players.length})`
      : formatTableState(table.m_state ?? "Shutdown")
      }
    </div>
  );
};
