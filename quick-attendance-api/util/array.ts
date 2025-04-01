export function map_to_2d<T>(arr: T[], col_size: number) {
  return Array.from(
    { length: Math.ceil(arr.length / col_size) },
    (_, i) => arr.slice(i * col_size, (i + 1) * col_size),
  );
}
