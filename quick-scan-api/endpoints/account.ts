import { Context, Hono } from "@hono/hono";
import { decode, sign, verify } from "npm:hono/jwt";
import { AccountPostReq } from "../models/account/account_post_req.ts";
import { AccountLoginPostReq } from "../models/account/account_login_post_req.ts";
import * as dal from "../dal/account.ts";
import { AccountLoginPostRes } from "../models/account/account_login_post_res.ts";
import { Uuid } from "../uuid.ts";
import HttpStatusCode from "../http_status_code.ts";

export const jwt_secret: string =
  "ca882e5c-dfd5-45fc-bc04-0a2fb7326305--86d452ef-778d-4443-812d-b19398b4e67f";
export const jwt_alg = "HS512";

const account_base_path = "/account";
const auth_account_base_path = `/auth${account_base_path}`;

const account = new Hono();

account.post(account_base_path, async (ctx: Context) => {
  const req = await ctx.req.json<AccountPostReq>();
  await dal.create_account(req);
  return ctx.text("ok");
});

account.get(auth_account_base_path, async (ctx: Context) => {
  const jwt = ctx.get("jwtPayload") as { user_id: Uuid };
  return ctx.json(await dal.get_account(jwt.user_id));
});

account.post(`${account_base_path}/login`, async (ctx: Context) => {
  // Parse request and send to dal
  const req = await ctx.req.json<AccountLoginPostReq>();
  const entity = await dal.login_account(req);

  // Create a JWT token that will last a week
  const payload = {
    iss: "quick-scan-api",
    sub: "user-auth",
    aud: "quick-scan-client",
    user_id: entity.user_id,
    exp: Math.round(((Date.now()) / 1000) + 86400 * 7),
  };
  const token = await sign(payload, jwt_secret, jwt_alg);

  return ctx.json({ jwt: token } as AccountLoginPostRes);
});

export { account };
