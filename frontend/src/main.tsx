import { StrictMode } from 'react';
import * as ReactDOM from 'react-dom/client';
import { RouterProvider, createRouter } from '@tanstack/react-router';

import { routeTree } from './routeTree.gen';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from './providers/QueryClient';
import ChainsProvider from './providers/ChainsProvider';

const router = createRouter({ routeTree });
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

root.render(
  // <StrictMode>
    <QueryClientProvider client={queryClient}>
      <ChainsProvider testnets={true}>
        <RouterProvider router={router} />
      </ChainsProvider>
    </QueryClientProvider>
  // </StrictMode>,
);
