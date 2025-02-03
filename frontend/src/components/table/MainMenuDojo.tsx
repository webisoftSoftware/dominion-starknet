import React from 'react';
import { TableListItem } from '@frontend/components/lobby/tableListItem';
import { useModels } from '@frontend/chains/starknet/DojoWrapper';

export function MainMenuDojo() {
  const unsorted_tables = useModels("ComponentTable");
  const tables = unsorted_tables
    .sort((a, b) => {
    // Ascending order.
    const aId = Number(a?.m_table_id);
    const bId = Number(b?.m_table_id);
    return aId - bId;
  });

  return (
    <div>
      {tables.length > 0 ? (
        <>
          <p>Available Tables ({tables.length})</p>
          <div className='flex flex-col gap-4 py-4'>
            {tables.map((table, index) => (
              <TableListItem
                table={{
                  m_id: Number(table?.m_table_id),
                  m_name: `Table #${table?.m_table_id ?? NaN}`,
                  m_minBuyIn: Number(table?.m_min_buy_in),
                  m_maxBuyIn: Number(table?.m_max_buy_in),
                  m_players: table?.m_players ?? [],
                  m_maxPlayers: 6,
                  m_smallBlind: Number(table?.m_small_blind ?? NaN),
                  m_bigBlind: Number(table?.m_big_blind ?? NaN),
                  m_state: table?.m_state.toString() ?? "N/A"
                }}
                index={index}
                key={table?.m_table_id?.toString() ?? index}
              />
            ))}
          </div>
        </>
      ) : (
        <p>No tables available</p>
      )}
    </div>
  );
}
