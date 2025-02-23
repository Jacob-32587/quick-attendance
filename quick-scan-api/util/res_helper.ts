import { DbErr } from "../dal/db.ts";
import { Context } from "@hono/hono";
import { ContentfulStatusCode } from "@hono/hono/utils/http-status";
import {
  InvalidJSONValue,
  JSONValue,
  SimplifyDeepArray,
} from "@hono/hono/utils/types";
import { Result } from "@result/result";

type DbRes<T> = (Result<T, never> | Result<never, DbErr>) | Result<T, DbErr>;

// ctx: Contex for the given request
// res: response from the database call
// data: optional data override, if provided the database return will be replaced with the given value
// ok_status_code: optional status code override, if provided the given status code will be used instead of 200
export function db_res_to_json_res<
  T extends JSONValue | SimplifyDeepArray<unknown> | InvalidJSONValue,
>(
  ctx: Context,
  res: DbRes<T>,
  data: T | undefined = undefined,
  ok_status_code: ContentfulStatusCode | undefined = undefined,
) {
  const api_res = res.map((val) => {
    switch (data) {
      case undefined:
        return ctx.json(
          val,
          ok_status_code === undefined ? 200 : ok_status_code,
        );
      default:
        return ctx.json(
          data,
          ok_status_code === undefined ? 200 : ok_status_code,
        );
    }
  }).mapErr((err) => {
    return ctx.json({ reason: err.reason }, err.status_code);
  });
  return api_res.innerResult.value;
}

export async function db_res_to_json_res_async<
  T extends JSONValue | SimplifyDeepArray<unknown> | InvalidJSONValue,
>(
  ctx: Context,
  res: Promise<DbRes<T>>,
  data: T | undefined = undefined,
  ok_status_code: ContentfulStatusCode | undefined = undefined,
) {
  return db_res_to_json_res(ctx, await res, data, ok_status_code);
}
