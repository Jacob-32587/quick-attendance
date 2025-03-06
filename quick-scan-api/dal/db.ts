import { ContentfulStatusCode } from "@hono/hono/utils/http-status";
import HttpStatusCode from "../http_status_code.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { Match } from "effect";

type KvNone = {
  key: Deno.KvKey;
  value: null;
  versionstamp: null;
};

// Then wrapper for errors specific to the database
export class DbErr {
  /**
   * @param reason - Reason for the error occurring
   * @param status_code - {@link HttpStatusCode} for the thrown http exception
   * @throw{@link HTTPException}
   * This function will always throw an http status exception. If the
   * status_code is not provided the default is {@link HttpStatusCode.INTERNAL_SERVER_ERROR}
   */
  public static err(
    reason: string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ): never {
    throw new HTTPException(status_code, {
      message: reason ?? "unspecified database error",
    });
  }

  /**
   * @description Throws an {@link HTTPException} if the commit result is the {@link Deno.KvCommitError} variant
   * @param commit_res - The result of the DenoKV commit function
   * @param reason - Error message thrown on commit error
   * @param status_code - {@link HttpStatusCode} thrown on commit error
   * @throw{@link HTTPException}
   */
  public static err_on_commit(
    commit_res: Deno.KvCommitResult | Deno.KvCommitError,
    reason: string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    Match.value(commit_res.ok).pipe(
      Match.when(false, () => DbErr.err(reason, status_code)),
      Match.when(true, (v) => v),
      Match.exhaustive,
    );
  }

  /**
   * @description Throws an {@link HTTPException} if any {@link Deno.KvEntryMaybe} has a null value.
   * @template T - The type of the value in the potential key value pair
   * @param maybe_kvs - List of potential key value pairs
   * @param reason - Error message throw if any version time stamp is null
   * @param status_code - {@link HttpStatusCode} thrown if any version time stamp is null
   * @throw{@link HTTPException}
   * @returns List of {@link Deno.KvEntry}
   */
  public static err_on_any_empty_vals<T>(
    maybe_kvs: Deno.KvEntryMaybe<T>[],
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    for (let i = 0; i < maybe_kvs.length; i++) {
      DbErr.err_on_empty_val(maybe_kvs[i], reason, status_code); //!! throw
    }
    return maybe_kvs as Deno.KvEntry<T>[];
  }

  /**
   * @description Throws an {@link HTTPException} if the {@link Deno.KvEntryMaybe} has a null value.
   * @template T - The type of the value in the potential key value pair
   * @param maybe_kv - Potential key value pair
   * @param reason - Error message throw if version time stamp is null
   * @param status_code - {@link HttpStatusCode} thrown if the version time stamp is null
   * @throw{@link HTTPException}
   * @returns Single {@link Deno.KvEntry}
   */
  public static err_on_empty_val<T>(
    maybe_kv: Deno.KvEntryMaybe<T>,
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ): Deno.KvEntry<T> {
    return Match.value(maybe_kv).pipe(
      Match.when(
        (v) => v.versionstamp == null,
        () => DbErr.err(reason(maybe_kv.key), status_code),
      ),
      Match.orElse((v) => v as Deno.KvEntry<T>),
    );
  }

  ////////////
  // Async //
  //////////

  /**
   * @description Throws an {@link HTTPException} if the commit result is the {@link Deno.KvCommitError} variant
   * @param commit_res - The result of the DenoKV commit function
   * @param reason - Error message thrown on commit error
   * @param status_code - {@link HttpStatusCode} thrown on commit error
   * @throw{@link HTTPException}
   * @returns promise that will resolve when the commit comes to a resolution
   */
  public static async err_on_commit_async(
    commit_res: Promise<Deno.KvCommitResult | Deno.KvCommitError>,
    reason: string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    return this.err_on_commit(await commit_res, reason, status_code);
  }

  /**
   * @description Throws an {@link HTTPException} if any {@link Deno.KvEntryMaybe} has a null value.
   * @template T - The type of the value in the potential key value pair
   * @param maybe_kvs - List of potential key value pairs
   * @param reason - Error message throw if any version time stamp is null
   * @param status_code - {@link HttpStatusCode} thrown if any version time stamp is null
   * @throw{@link HTTPException}
   * @returns Promise that will resolve to a list of {@link Deno.KvEntry} objects
   */
  public static async err_on_empty_vals_async<T>(
    maybe_kvs: Iterable<Promise<Deno.KvEntryMaybe<T>>>,
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    return await Promise.all(maybe_kvs).then((maybe_vals) => {
      return DbErr.err_on_any_empty_vals(
        maybe_vals,
        reason,
        status_code,
      );
    }).catch((e) => {
      console.timeLog(e);
      throw new HTTPException(HttpStatusCode.INTERNAL_SERVER_ERROR, {
        message: "Unable to resolve all promises",
      });
    });
  }

  /**
   * @description Throws an {@link HTTPException} if the {@link Deno.KvEntryMaybe} has a null value.
   * @template T - The type of the value in the potential key value pair
   * @param maybe_kv - Potential key value pair
   * @param reason - Error message throw if version time stamp is null
   * @param status_code - {@link HttpStatusCode} thrown if the version time stamp is null
   * @throw{@link HTTPException}
   * @return Promise that will resolve to a @{link Deno.KvEntry} object
   */
  public static async err_on_empty_val_async<T>(
    maybe_kv: Promise<Deno.KvEntryMaybe<T>>,
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    return DbErr.err_on_empty_val(await maybe_kv, reason, status_code);
  }
}

export class KvHelper {
  /**
   * @template T - The type of the value in the potential key value pair
   * @param maybe_vals - List of potential key value pairs
   * @returns List of @{link Deno.KvEntry} objects
   */
  public static remove_kv_nones<T>(
    maybe_vals: Deno.KvEntryMaybe<T>[],
  ) {
    return maybe_vals.filter((x) => x.versionstamp != null) as Deno.KvEntry<
      T
    >[];
  }

  /**
   * @template T - The type of the value in the potential key value pair
   * @param maybe_vals - List of potential key value pairs
   * @returns Promise that will resolve to a list of @{link Deno.KvEntry} objects
   */
  public static async remove_kv_nones_async<T>(
    maybe_vals: Promise<Deno.KvEntryMaybe<T>[]>,
  ) {
    return this.remove_kv_nones<T>(await maybe_vals);
  }
}

export default await Deno.openKv("./db.sqlite");
