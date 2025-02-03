type Predicate<T> = ((item: T) => unknown) | keyof T;

/**
 * Dedup elements in an array using a predicate or a specific key
 * @param arr
 * @param predicate
 */
export const uniqBy = <T extends Record<string, unknown>>(arr: T[], predicate: Predicate<T>): T[] => {
  const cb: Predicate<T> = typeof predicate === 'function' ? predicate : (o) => o[predicate];

  return [
    ...arr
      .reduce((map, item) => {
        const key = item === null || item === undefined ? item : cb(item);

        map.has(key) || map.set(key, item);

        return map;
      }, new Map())
      .values(),
  ];
};
