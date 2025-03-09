import { Context, Hono } from "npm:hono";
import { jwt } from "npm:hono/jwt";
import HttpStatusCode from "./http_status_code.ts";
import { account, jwt_alg, jwt_secret } from "./endpoints/account.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { Uuid } from "./uuid.ts";
import { group } from "./endpoints/group.ts";
import { cli_flags } from "./cli_parse.ts";
import { instanceOfJwtException } from "./util/jwt.ts";
import { HTTPResponseError } from "@hono/hono/types";
const app = new Hono().basePath("/quick-scan-api");

export { app };

export interface QuickScanJwtPayload {
  [key: string]: unknown;
  iss: string;
  sub: string;
  aud: string;
  user_id: Uuid;
  exp: number;
  nbf: number;
  iat: number;
}

export interface AuthJwtPayload extends QuickScanJwtPayload {
  iss: "quick-scan-api";
  sub: "user-auth";
  aud: "quick-scan-client";
}

app.use(
  "/auth/*",
  jwt({
    secret: jwt_secret,
    alg: jwt_alg,
  }),
);

export function get_jwt_payload(ctx: Context) {
  return ctx.get("jwtPayload") as QuickScanJwtPayload;
}

app.onError((err, ctx) => {
  // Allow explicit HTTPExceptions to propagate through, otherwise return a generic
  // internal server error
  if (err instanceof HTTPException) {
    return ctx.json({ message: err.message, cause: err.cause }, err.status);
  } else if (instanceOfJwtException(err)) {
    return ctx.json(
      { message: err.message, cause: err.cause },
      HttpStatusCode.UNAUTHORIZED,
    );
  } else if ("getResponse" in err) {
    // If an unauthorized error is being propagated we will allow it
    if (err.getResponse().status === HttpStatusCode.UNAUTHORIZED) {
      ctx.res = err.getResponse();
      return ctx.res;
    }
  }

  console.log("Uncaught error: ", err);
  return ctx.json(
    "internal server error",
    HttpStatusCode.INTERNAL_SERVER_ERROR,
  );
});

app.get("/", (ctx: Context) => {
  return ctx.json({ utc_time: (new Date()).toUTCString() }, HttpStatusCode.OK);
});
app.route("", account);
app.route("", group);

console.log(cli_flags["test-number"]);
console.log(parseInt(cli_flags["test-number"]));

export const server = Deno.serve({
  port: parseInt(cli_flags["test-number"]) + 8080,
}, app.fetch);
