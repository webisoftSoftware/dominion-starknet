import { getRouterContext, Outlet, useMatches } from '@tanstack/react-router';
import { useIsPresent, motion, MotionProps } from 'framer-motion';
import cloneDeep from 'lodash/cloneDeep';
import { forwardRef, useContext, useRef } from 'react';

export const AnimatedOutlet = forwardRef<HTMLDivElement, MotionProps>((props, ref) => {
  const isPresent = useIsPresent();

  const matches = useMatches();
  const prevMatches = useRef(matches);

  const RouterContext = getRouterContext();
  const routerContext = useContext(RouterContext);

  let renderedContext = routerContext;

  if (isPresent) {
    prevMatches.current = cloneDeep(matches);
  } else {
    renderedContext = cloneDeep(routerContext);
    renderedContext.__store.state.matches = [
      ...matches.map((m, i) => ({
        ...(prevMatches.current[i] || m),
        id: m.id,
      })),
      ...prevMatches.current.slice(matches.length),
    ];
  }

  return (
    <motion.div ref={ref} {...props}>
      <RouterContext.Provider value={renderedContext}>
        <Outlet />
      </RouterContext.Provider>
    </motion.div>
  );
});
