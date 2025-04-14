import { HTTPException } from "@hono/hono/http-exception";
import { zValidator } from "npm:@hono/zod-validator";
import { Hono } from "npm:hono";
import { sign, verify } from "npm:hono/jwt";
import * as dal from "../dal/account.ts";
import kv, { DbErr } from "../dal/db.ts";
import * as group_dal from "../dal/group.ts";
import { get_jwt_payload, QuickAttendanceJwtPayload } from "../main.ts";
import AccountGetModel from "../models/account/account_get_model.ts";
import { account_invite_put_req } from "../models/account/account_invite_accept_put_req.ts";
import { account_login_post_req } from "../models/account/account_login_post_req.ts";
import { AccountLoginPostRes } from "../models/account/account_login_post_res.ts";
import { account_post_req_val } from "../models/account/account_post_req.ts";
import { account_put_req_val } from "../models/account/account_put_req.ts";
import { group_invite_jwt_payload } from "../models/group_invite_jwt_payload.ts";
import HttpStatusCode from "../util/http_status_code.ts";

export const jwt_secret: string =
  "ca882e5c-dfd5-45fc-bc04-0a2fb7326305--86d452ef-778d-4443-812d-b19398b4e67f";
export const jwt_alg = "HS512";

const account_base_path = "/account";
const auth_account_base_path = `/auth${account_base_path}`;

const account = new Hono();

//#region Query

// Get account information
account.get(auth_account_base_path, async (ctx) => {
  const entity = (await dal.get_account(get_jwt_payload(ctx).user_id)).value;
  return ctx.json({
    username: entity.username,
    email: entity.email,
    first_name: entity.first_name,
    last_name: entity.last_name,
    user_id: entity.user_id,
    fk_pending_group_ids: entity.fk_pending_group_invites?.entries().map((x) => x[1])
      .toArray(),
  } as AccountGetModel);
});

//#endregion

//#region Mutation
account.post(
  account_base_path,
  zValidator("json", account_post_req_val),
  async (ctx) => {
    const req = ctx.req.valid("json");
    await dal.create_account(req);
    return ctx.text("ok");
  },
);

account.put(
  auth_account_base_path,
  zValidator("json", account_put_req_val),
  async (ctx) => {
    const req = ctx.req.valid("json");
    await dal.update_account_from_req(get_jwt_payload(ctx).user_id, req);
    return ctx.text("ok");
  },
);

// Login an account, returns a JWT that can be used for authenticated request
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
      iss: "quick-attendance-api",
      sub: "user-auth",
      aud: "quick-attendance-client",
      user_id: entity.user_id,
      exp: exp,
      // This is necessary so requests can be made within the same second
      // the token was issued at.
      nbf: iat,
      iat: iat,
    } as QuickAttendanceJwtPayload;
    const token = await sign(payload, jwt_secret, jwt_alg);

    return ctx.json({ jwt: token } as AccountLoginPostRes);
  },
);

// Accept or deny a group invitation
account.put(
  `${auth_account_base_path}/invite`,
  zValidator("json", account_invite_put_req),
  async (ctx) => {
    console.log("Hit");
    // Parse request and send to dal
    const req = ctx.req.valid("json");
    let jwt_payload;
    try {
      jwt_payload = await verify(
        req.account_invite_jwt,
        jwt_secret,
        jwt_alg,
      );
    } catch (_) {
      throw new HTTPException(HttpStatusCode.FORBIDDEN, {
        message: "Invite JWT invalid",
      });
    }

    const user_jwt = get_jwt_payload(ctx);
    const maybe_invite_jwt = await group_invite_jwt_payload.safeParseAsync(
      jwt_payload,
    );

    if (!maybe_invite_jwt.success) {
      return ctx.json(maybe_invite_jwt, HttpStatusCode.BAD_REQUEST);
    }

    const invite_jwt = maybe_invite_jwt.data;

    const tran = kv.atomic();
    // Accept or deny the group invitation, update the account information appropriately
    const account_mut_promise = dal.respond_to_group_invite(
      user_jwt.user_id,
      invite_jwt.group_id,
      req.accept,
      invite_jwt.is_manager_invite,
      req.unique_id,
      tran,
    );
    // Accept or deny the group invitation, update the group information appropriately
    // This will also verify that the unique id sent follows the group specifications
    await group_dal.respond_to_group_invite(
      user_jwt.user_id,
      invite_jwt.group_id,
      req.accept,
      invite_jwt.is_manager_invite,
      req.unique_id,
      tran,
    );
    await account_mut_promise;

    await DbErr.err_on_commit_async(
      tran.commit(),
      "Unable to take invite action",
    );

    return ctx.text("");
  },
);

//#endregion

export { account };
