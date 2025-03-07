import { Context, Hono } from "npm:hono";
import { jwt } from "npm:hono/jwt";
import HttpStatusCode from "./http_status_code.ts";
import { account, jwt_alg, jwt_secret } from "./endpoints/account.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { Uuid } from "./uuid.ts";
import { group } from "./endpoints/group.ts";

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
  }
  console.timeLog("Uncaught error: ", err);
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
Deno.serve({ port: 8080 }, app.fetch);
