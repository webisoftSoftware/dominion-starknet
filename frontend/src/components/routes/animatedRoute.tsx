import { type HTMLMotionProps, motion, type Variants } from 'framer-motion';

type Direction = 'left' | 'right' | 'up' | 'down';
type Directions = {
  enter: Direction;
  exit: Direction;
};

type AnimateRouteProps = HTMLMotionProps<'div'> & {
  direction?: Direction | Directions;
};

const OFFSET: Record<Direction, 1 | -1> = {
  left: 1,
  right: -1,
  up: 1,
  down: -1,
};

const AXIS: Record<Direction, 'x' | 'y'> = {
  left: 'x',
  right: 'x',
  up: 'y',
  down: 'y',
};

const defaultDirections: Directions = {
  enter: 'left',
  exit: 'right',
};
export const RouteTransitionVariants: Variants = {
  initial: (direction: Directions = defaultDirections) => ({
    [AXIS[direction.enter]]: `${OFFSET[direction.enter] * 100}vw`,
    opacity: 0,
  }),
  animate: (direction: Directions = defaultDirections) => ({
    [AXIS[direction.enter]]: 0,
    opacity: 1,
  }),
  exit: (direction: Directions = defaultDirections) => ({
    [AXIS[direction.exit]]: `${OFFSET[direction.exit] * -100}vw`,
    opacity: 0,
  }),
};

export const TransitionProps = {
  variants: RouteTransitionVariants,
  initial: 'initial',
  animate: 'animate',
  exit: 'exit',
  transition: {
    type: 'spring',
    stiffness: 200,
    damping: 24,
  },
} as const;

export const AnimatedRoute = (props: AnimateRouteProps) => {
  const directions =
    typeof props.direction === 'string' ? { enter: props.direction, exit: props.direction } : props.direction;

  return (
    <motion.div custom={directions} {...TransitionProps} {...props}>
      {props.children}
    </motion.div>
  );
};
