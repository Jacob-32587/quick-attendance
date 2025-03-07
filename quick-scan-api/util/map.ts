import { HTTPException } from "@hono/hono/http-exception";
import { ContentfulStatusCode } from "@hono/hono/utils/http-status";

/**
 * @description This function will add to a map that may not be defined yet. If the
 * map is not defined then a new instance will be created and returned. If the map was
 * defined the same instance of the provided map will be returned. If an error status code
 * is provided the function will throw an {@link HTTPException} on duplicate value inserts.
 * @template K - Key type in the map
 * @template V - Value type in the map
 * @param m - Map of key value pairs
 * @param kvs - key value pairs to insert into the map
 * @param err_status_code - Status code to be thrown on duplicate key inserts
 * @param err_reason - Reason message to be thrown on duplicate key inserts
 * @returns Map with keys and values inserted
 * @throw{@link HTTPException}: This function will throw if the key already exists in the map
 */
export function add_to_maybe_map<K, V>(
  m: Map<K, V> | null | undefined,
  kvs: [K, V][],
  err_status_code?: ContentfulStatusCode,
  err_reason?: string,
) {
  if (m === null || m === undefined) {
    const map_ret = new Map(kvs);

    if (
      err_status_code !== undefined &&
      map_ret.entries().toArray().length != kvs.length
    ) {
      throw new HTTPException(err_status_code, { message: err_reason });
    }
    return map_ret;
  }

  for (let i = 0; i < kvs.length; i++) {
    if (err_status_code !== undefined && m.has(kvs[i][0])) {
      throw new HTTPException(err_status_code, { message: err_reason });
    }
    m.set(kvs[i][0], kvs[i][1]);
  }
  return m;
}

/**
 * @description This function will add to a set that may not be defined yet. If the
 * set is not defined then a new instance will be created and returned. If the set was
 * defined the same instance of the provided set will be returned. If an error status code
 * is provided the function will throw an {@link HTTPException} on duplicate value inserts.
 * @template K - Key type in the set
 * @param s - Set of keys
 * @param ks - Keys to insert into th set
 * @param err_status_code - Status code to be thrown on duplicate key inserts
 * @param err_reason - Reason message to be thrown on duplicate key inserts
 * @returns Set with keys inserted
 * @throw{@link HTTPException}: This function will throw if the key already exists in the set
 */
export function add_to_maybe_set<K>(
  s: Set<K> | null | undefined,
  ks: K[],
  err_status_code?: ContentfulStatusCode,
  err_reason?: string,
) {
  if (s === null || s === undefined) {
    const set_ret = new Set(ks);

    if (
      err_status_code !== undefined &&
      set_ret.entries().toArray().length != ks.length
    ) {
      throw new HTTPException(err_status_code, { message: err_reason });
    }
    return set_ret;
  }

  for (let i = 0; i < ks.length; i++) {
    if (err_status_code !== undefined && s.has(ks[i])) {
      throw new HTTPException(err_status_code, { message: err_reason });
    }
    s.add(ks[i]);
  }
  return s;
}
