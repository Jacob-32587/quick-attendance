import { Context, Hono } from "@hono/hono";
import { jwt } from "@hono/hono/jwt";
import HttpStatusCode from "./http_status_code.ts";
import { account, jwt_alg, jwt_secret } from "./endpoints/account.ts";

const app = new Hono().basePath("/quick-scan-api");

export { app };

app.use(
  "/auth/*",
  jwt({
    secret: jwt_secret,
    alg: jwt_alg,
  }),
);

app.get("/", (ctx: Context) => {
  return ctx.json({ utc_time: (new Date()).toUTCString() }, HttpStatusCode.OK);
});
app.route("", account);
Deno.serve({ port: 8080 }, app.fetch);
