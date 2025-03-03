import { ContentfulStatusCode } from "@hono/hono/utils/http-status";
import HttpStatusCode from "../http_status_code.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { Match } from "effect";

// Then wrapper for errors specific to the database
export class DbErr {
  public static err(
    reason: string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ): never {
    throw new HTTPException(status_code, {
      message: reason ?? "unspecified reason",
    });
  }

  // Sync
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

  public static err_on_any_empty_vals<T>(
    maybe_kvs: Iterable<Deno.KvEntryMaybe<T>>,
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    for (const maybe_kv of maybe_kvs) {
      DbErr.err_on_empty_val(maybe_kv, reason, status_code);
    }
  }

  public static err_on_empty_val<T>(
    maybe_kv: Deno.KvEntryMaybe<T>,
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    return Match.value(maybe_kv.value).pipe(
      Match.when(null, () => DbErr.err(reason(maybe_kv.key), status_code)),
      Match.orElse((val) => val),
    ) as Exclude<T, null>;
  }

  // Async
  public static err_on_empty_vals_async<T>(
    maybe_kvs: Iterable<Promise<Deno.KvEntryMaybe<T>>>,
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    return Promise.all(maybe_kvs).then((maybe_vals) =>
      DbErr.err_on_any_empty_vals(
        maybe_vals,
        reason,
        status_code,
      )
    ).catch((e) => {
      console.timeLog(e);
      throw new HTTPException(HttpStatusCode.INTERNAL_SERVER_ERROR, {
        message: "Unable to resolve all promises",
      });
    });
  }

  public static async err_on_empty_val_async<T>(
    maybe_kv: Promise<Deno.KvEntryMaybe<T>>,
    reason: (key: Deno.KvKey) => string | null,
    status_code: ContentfulStatusCode = HttpStatusCode.INTERNAL_SERVER_ERROR,
  ) {
    return DbErr.err_on_empty_val(await maybe_kv, reason, status_code);
  }
}

export default await Deno.openKv("./db.sqlite");
