import { toast } from 'react-hot-toast';

/**
 * Handle errors by logging them and showing a toast notification.
 * @param error
 */
export const handleErrors = (error: Error) => {
  console.error(error);
  toast.error(error.message);
};
