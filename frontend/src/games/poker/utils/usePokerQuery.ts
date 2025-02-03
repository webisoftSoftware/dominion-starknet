import { useQuery, type UseQueryOptions, type UseQueryResult } from '@tanstack/react-query';
import React from 'react';

import type { QueryFnParams, QueryFnResult } from '@frontend/games/poker/client';
import type { PokerClient } from '@frontend/games/poker/client/PokerClient';
import { handleErrors } from '@frontend/library/errors';
import { usePokerClient } from './hooks';

interface UsePokerQueryProps<Action extends keyof PokerClient> {
  action: Action;
  params: QueryFnParams<PokerClient[Action]>;
}

type UseQueryOptionsExcerpt = Omit<UseQueryOptions, 'queryKey' | 'queryFn'>;

export const usePokerQuery = <Action extends keyof PokerClient, Result extends QueryFnResult<PokerClient[Action]>>(
  { action, params }: UsePokerQueryProps<Action>,
  options: UseQueryOptionsExcerpt = {},
): UseQueryResult<Result> => {
  const pokerClient = usePokerClient();

  const query = useQuery({
    queryKey: [pokerClient.getChainId(), action, params],
    queryFn: () => {
      const fn = pokerClient[action] as PokerClient[Action];
      return fn(params as any);
    },
    ...options,
  }) as UseQueryResult<Result>;

  React.useEffect(() => {
    if (query.isError) {
      handleErrors(query.error);
    }
  }, [query.error, query.isError]);

  return query;
};
