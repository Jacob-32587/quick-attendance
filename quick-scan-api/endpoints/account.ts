import { Hono } from "npm:hono";
import { Uuid } from "../uuid.ts";
import { sign } from "npm:hono/jwt";
import { account_post_req_val } from "../models/account/account_post_req.ts";
import {
  account_login_post_req,
} from "../models/account/account_login_post_req.ts";
import { AccountLoginPostRes } from "../models/account/account_login_post_res.ts";
import { zValidator } from "npm:@hono/zod-validator";
import * as dal from "../dal/account.ts";
import { get_jwt_payload, QuickScanJwtPayload } from "../main.ts";
import AccountGetModel from "../models/account/account_get_model.ts";

export const jwt_secret: string =
  "ca882e5c-dfd5-45fc-bc04-0a2fb7326305--86d452ef-778d-4443-812d-b19398b4e67f";
export const jwt_alg = "HS512";

const account_base_path = "/account";
const auth_account_base_path = `/auth${account_base_path}`;

const account = new Hono();

account.post(
  account_base_path,
  zValidator("json", account_post_req_val),
  async (ctx) => {
    const req = ctx.req.valid("json");
    await dal.create_account(req);
    return ctx.text("ok");
  },
);

account.get(auth_account_base_path, async (ctx) => {
  const entity = await dal.get_account(get_jwt_payload(ctx).user_id);
  return ctx.json({
    username: entity.username,
    email: entity.email,
    first_name: entity.first_name,
    last_name: entity.last_name,
    user_id: entity.user_id,
    fk_owned_group_ids: entity.fk_owned_group_ids,
    fk_managed_group_ids: entity.fk_managed_group_ids,
    fk_member_group_ids: entity.fk_member_group_ids,
    fk_pending_group_ids: entity.fk_pending_group_invites,
    versionstamp: entity.versionstamp,
  } as AccountGetModel);
});

account.post(
  `${account_base_path}/login`,
  zValidator("json", account_login_post_req),
  async (ctx) => {
    // Parse request and send to dal
    const req = ctx.req.valid("json");
    const entity = await dal.login_account(req);

    const iat = Math.round(Date.now() / 1000) - 1;
    const exp = iat + 86400 * 7;
    // Create a JWT token that will last a week
    const payload = {
      iss: "quick-scan-api",
      sub: "user-auth",
      aud: "quick-scan-client",
      user_id: entity.user_id,
      exp: exp,
      // This is necessary so requests can be made within the same second
      // the token was issued at.
      nbf: iat,
      iat: iat,
    } as QuickScanJwtPayload;
    const token = await sign(payload, jwt_secret, jwt_alg);

    return ctx.json({ jwt: token } as AccountLoginPostRes);
  },
);

export { account };
