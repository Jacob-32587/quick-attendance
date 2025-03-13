import { Hono } from "npm:hono";
import { zValidator } from "npm:@hono/zod-validator";
import * as dal from "../dal/group.ts";
import * as account_dal from "../dal/account.ts";
import { group_post_req } from "../models/group/group_post_req.ts";
import { get_jwt_payload } from "../main.ts";
import HttpStatusCode from "../util/http_status_code.ts";
import { group_invite_put_req } from "../models/group/group_invite_put_req.ts";
import kv, { DbErr } from "../dal/db.ts";
import { jwt_alg, jwt_secret } from "./account.ts";
import { verify } from "npm:hono/jwt";
import { group_unique_id_settings_get_req } from "../models/group/group_unique_id_settings_get_req.ts";
import { group_invite_jwt_payload } from "../models/group_invite_jwt_payload.ts";
import { GroupPostRes } from "../models/group/group_post_res.ts";
import { group_get_req } from "../models/group/group_get_req.ts";

const group_base_path = "/group";
const auth_group_base_path = `/auth${group_base_path}`;

const group = new Hono();

//#region Query

// Get a group for the given user
group.get(
  `${auth_group_base_path}`,
  zValidator("json", group_get_req),
  async (ctx) => {
    const group = (await dal.get_group(get_jwt_payload(ctx).user_id)).value;
    // Match.
    // account_dal.get_public_account_models(group.member_ids);
    return ctx.json(res, HttpStatusCode.OK);
  },
);

// List all the accounts that a user owners, manages, and is a member of
group.get(
  `${auth_group_base_path}/list`,
  async (ctx) => {
    const res = await dal.get_groups_for_account(get_jwt_payload(ctx).user_id);
    return ctx.json(res, HttpStatusCode.OK);
  },
);

//#endregion

//#region Mutation
group.post(
  auth_group_base_path,
  zValidator("json", group_post_req),
  async (ctx) => {
    const req = ctx.req.valid("json");
    const group_entity = await dal.create_group(
      get_jwt_payload(ctx).user_id,
      req,
    );
    return ctx.json(
      { group_id: group_entity.group_id } as GroupPostRes,
      HttpStatusCode.OK,
    );
  },
);

group.put(
  `${auth_group_base_path}/invite`,
  zValidator("json", group_invite_put_req),
  async (ctx) => {
    const req = ctx.req.valid("json");
    const tran = kv.atomic();

    // Verify the group is owned by the users and get user accounts to invite
    const { owner_entity, account_entities } = await dal
      .accounts_for_group_invite(
        tran,
        get_jwt_payload(ctx).user_id,
        req.group_id,
        req.usernames,
      );
    const group_entity = await dal.get_group(req.group_id);

    // Set account pending invites for the transaction
    await account_dal.invite_accounts_to_group(
      tran,
      req.group_id,
      group_entity.value.group_name,
      owner_entity.user_id,
      req.is_manager_invite,
      account_entities.map((x) => x.value),
    );

    DbErr.err_on_commit_async(tran.commit(), "Unable to invite users");

    return ctx.text("", HttpStatusCode.OK);
  },
);

group.put(
  `${auth_group_base_path}/unique-id-settings`,
  zValidator("json", group_unique_id_settings_get_req),
  async (ctx) => {
    // Parse request and send to dal
    const req = ctx.req.valid("json");
    const jwt_payload = await verify(
      req.account_invite_jwt,
      jwt_secret,
      jwt_alg,
    );
    const jwt = await group_invite_jwt_payload.parseAsync(jwt_payload);
    const group_entity = (await dal.get_group(jwt.group_id)).value;

    return ctx.json(group_entity.unique_id_settings);
  },
);

//#endregion

export { group };
