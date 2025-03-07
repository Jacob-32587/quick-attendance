import { Hono } from "npm:hono";
import { zValidator } from "npm:@hono/zod-validator";
import * as dal from "../dal/group.ts";
import * as account_dal from "../dal/account.ts";
import { group_post_req } from "../models/group/group_post_req.ts";
import { get_jwt_payload } from "../main.ts";
import HttpStatusCode from "../http_status_code.ts";
import { group_invite_put_req } from "../models/group/group_invite_put_req.ts";
import kv, { DbErr } from "../dal/db.ts";

const group_base_path = "/group";
const auth_group_base_path = `/auth${group_base_path}`;

const group = new Hono();

group.post(
  auth_group_base_path,
  zValidator("json", group_post_req),
  async (ctx) => {
    const req = ctx.req.valid("json");
    await dal.create_group(get_jwt_payload(ctx).user_id, req);
    return ctx.text("", HttpStatusCode.OK);
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

    // Set account pending invites for the transaction
    await account_dal.invite_accounts_to_group(
      tran,
      req.group_id,
      owner_entity.user_id,
      account_entities.map((x) => x.value),
    );

    DbErr.err_on_commit_async(tran.commit(), "Unable to invite users");

    return ctx.text("", HttpStatusCode.OK);
  },
);

group.get(
  `${auth_group_base_path}/list`,
  async (ctx) => {
    const res = await dal.get_groups_for_account(get_jwt_payload(ctx).user_id);
    return ctx.json(res, HttpStatusCode.OK);
  },
);

export { group };
