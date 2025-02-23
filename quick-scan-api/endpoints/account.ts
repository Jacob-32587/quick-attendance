import { Context, Hono } from "@hono/hono";
import { decode, sign, verify } from "npm:hono/jwt";
import { AccountPostReq } from "../models/account/account_post_req.ts";
import { AccountLoginPostReq } from "../models/account/account_login_post_req.ts";
import * as dal from "../dal/account.ts";
import {
  db_res_to_json_res,
  db_res_to_json_res_async,
} from "../util/res_helper.ts";
import { AccountLoginPostRes } from "../models/account/account_login_post_res.ts";

const account = new Hono().basePath("/account");

account.post("/", async (ctx: Context) => {
  const req = await ctx.req.json<AccountPostReq>();
  return db_res_to_json_res_async(ctx, dal.create_account(req));
});

account.post("/login", async (ctx: Context) => {
  // Parse request and send to dal
  const req = await ctx.req.json<AccountLoginPostReq>();
  const dal_res = await dal.login_account(req);

  // If any errors occurred return
  if (dal_res.isErr()) {
    return db_res_to_json_res(ctx, dal_res);
  }
  const user = dal_res.ok()!;

  // Create a JWT token that will last a week
  const payload = {
    iss: "quick-scan-api",
    sub: "user-auth",
    aud: "quick-scan-client",
    user_id: user.user_id,
    exp: Math.round(((Date.now()) / 1000) + 86400 * 7),
  };
  const secret =
    "ca882e5c-dfd5-45fc-bc04-0a2fb7326305--86d452ef-778d-4443-812d-b19398b4e67f";
  const token = await sign(payload, secret, "HS512");

  return ctx.json({ jwt: token } as AccountLoginPostRes);
});

export { account };
