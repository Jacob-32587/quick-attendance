export function data_views_are_equal(a: DataView, b: DataView) {
  if (a.byteLength !== b.byteLength) return false;
  for (let i = 0; i < a.byteLength; i++) {
    if (a.getUint8(i) !== b.getUint8(i)) {
      return false;
    }
  }
  return true;
}
