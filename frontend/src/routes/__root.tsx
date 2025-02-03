import { AnimatedOutlet } from '@frontend/components/routes/animatedOutlet';
import { createRootRoute, useMatch, useMatches } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/router-devtools';
import { AnimatePresence } from 'framer-motion';

const Root = () => {
  const matches = useMatches();
    const match = useMatch({ strict: false });
    const nextMatchIndex = matches.findIndex((d) => d.id === match.id) + 1;
    const nextMatch = matches[nextMatchIndex];

    return (
      <AnimatePresence mode="popLayout">
        <AnimatedOutlet key={nextMatch?.id ?? ''} />
      </AnimatePresence>
    );
}

export const Route = createRootRoute({
  component: Root,
});
