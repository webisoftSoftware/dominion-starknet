/**
 * Suspend for the given amount of milliseconds.
 * @param ms
 */
export const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
