import { Context, Hono } from "@hono/hono";
import HttpStatusCode from "./http_status_code.ts";
import { account } from "./endpoints/account.ts";

const app = new Hono().basePath("/quick-scan-api");

export { app };

app.get("/", (ctx: Context) => {
  return ctx.json({ utc_time: (new Date()).toUTCString() }, HttpStatusCode.OK);
});
app.route("", account);
Deno.serve({ port: 8080 }, app.fetch);
