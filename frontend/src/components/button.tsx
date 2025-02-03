import { cn } from '@frontend/utils/cn';

export type ButtonVariant = 'primary' | 'secondary' | 'error';
type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  children: React.ReactNode;
  variant?: ButtonVariant;
  compact?: boolean;
  fullWidth?: boolean;
};
export const Button = ({ children, variant = 'primary', fullWidth, compact, className, ...props }: Props) => {
  return (
    <button
      className={cn(
        'text-text-primary flex items-center justify-center gap-2 rounded-full px-6 py-2 transition-opacity duration-200 disabled:opacity-40',
        variant === 'primary' && 'bg-accent',
        variant === 'secondary' && 'bg-tertiary',
        variant === 'error' && 'bg-error',
        fullWidth && 'w-full',
        compact && 'text-text-secondary gap-1 px-4 text-sm font-medium',
        className,
      )}
      {...props}
    >
      {children}
    </button>
  );
};
