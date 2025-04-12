import { Hono } from "npm:hono";
import { zValidator } from "npm:@hono/zod-validator";
import * as dal from "../dal/group.ts";
import * as account_dal from "../dal/account.ts";
import * as attendance_dal from "../dal/attendance.ts";
import { group_post_req } from "../models/group/group_post_req.ts";
import { get_jwt_payload, ws } from "../main.ts";
import HttpStatusCode from "../util/http_status_code.ts";
import { group_invite_put_req } from "../models/group/group_invite_put_req.ts";
import kv, { DbErr } from "../dal/db.ts";
import { group_put_request } from "../models/group/group_unique_id_settings_get_req.ts";
import { GroupPostRes } from "../models/group/group_post_res.ts";
import { group_get_req } from "../models/group/group_get_req.ts";
import { is_privileged_user_type, UserType } from "../models/user_type.ts";
import { GroupGetRes } from "../models/group/group_get_res.ts";
import { PublicAccountGetModel } from "../models/account/public_account_get_model.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { get_maybe_uuid_time, get_uuid_time } from "../util/uuid.ts";
import { date_add } from "../util/time.ts";

const group_base_path = "/group";
const auth_group_base_path = `/auth${group_base_path}`;

const group = new Hono();

//#region Query

// Get the group for the given user
group.get(
  `${auth_group_base_path}`,
  zValidator("query", group_get_req),
  async (ctx) => {
    const req = ctx.req.valid("query");
    const user_id = get_jwt_payload(ctx).user_id;

    // Determine what the type of the user is
    const account = await account_dal.get_account(user_id);
    let user_type: UserType;
    if (account.value.fk_owned_group_ids?.has(req.group_id) === true) {
      user_type = UserType.Owner;
    } else if (account.value.fk_managed_group_ids?.has(req.group_id) === true) {
      user_type = UserType.Manager;
    } else if (account.value.fk_member_group_ids?.has(req.group_id) === true) {
      user_type = UserType.Member;
    } else {
      throw new HTTPException(HttpStatusCode.NOT_FOUND, {
        message: "User does not belong to the specified group",
      });
    }

    const group_users_p = dal.get_group_users(req.group_id);

    const [group, _] = await dal.get_group_and_verify_user_type(
      req.group_id,
      user_id,
      user_type,
    );

    const group_users = await group_users_p;

    const user_get_promise = account_dal.get_public_account_models(
      group_users.map((x) => x.value.user_id),
      req.group_id,
    );

    const owner_get_promise = account_dal.get_public_account_models(
      [group.value.owner_id],
      req.group_id,
    );

    let pending_accounts = Promise.resolve(
      null as PublicAccountGetModel[] | null,
    );

    const last_attendance = await attendance_dal.get_most_recent_attendance_entity(req.group_id);

    // If the users is allowed to see pending users include in the response
    if (is_privileged_user_type(user_type)) {
      const pending_users = await dal.get_group_pending_users(req.group_id);
      pending_accounts = account_dal.get_public_account_models(
        pending_users.map((x) => x.value.user_id),
      );
    }

    const account_promises = await Promise.all([
      owner_get_promise,
      user_get_promise,
      pending_accounts,
    ]);

    const get_group_res: GroupGetRes = {
      group_id: group.value.group_id,
      group_name: group.value.group_name,
      group_description: group.value.group_description,
      current_attendance_id: group.value.current_attendance_id,
      event_count: group.value.event_count,
      owner: account_promises[0][0],
      members: account_promises[1].filter((x) => x.user_type === UserType.Member),
      managers: account_promises[1].filter((x) => x.user_type === UserType.Manager),
      last_attendance_date: get_maybe_uuid_time(last_attendance?.value.attendance_id) ?? null,
      pending_members: account_promises[2],
    };

    return ctx.json(get_group_res, HttpStatusCode.OK);
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
    const group_entity = await dal.create_group_from_req(
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
        get_jwt_payload(ctx).user_id,
        req.group_id,
        req.usernames,
        tran,
      );
    const group_entity = await dal.get_group(req.group_id);

    // Set account pending invites for the transaction
    await account_dal.invite_accounts_to_group(
      req.group_id,
      group_entity.value.group_name,
      owner_entity.value.user_id,
      req.is_manager_invite,
      account_entities,
      tran,
    );

    await DbErr.err_on_commit_async(
      tran.commit(),
      "Unable to invite users, check that the none of the users are already invited/part of the group",
      HttpStatusCode.CONFLICT,
    );

    return ctx.text("", HttpStatusCode.OK);
  },
);

group.put(
  `${auth_group_base_path}`,
  zValidator("json", group_put_request),
  async (ctx) => {
    const req = ctx.req.valid("json");

    const [group, user_type] = await dal.get_group_and_verify_user_type(
      req.group_id,
      get_jwt_payload(ctx).user_id,
      [
        UserType.Owner,
        UserType.Manager,
      ],
    );

    // The client needs to stop attedance, disconnect all connected websockets
    if (req.current_attendance_id === null && group.value.current_attendance_id !== null) {
      const group_users = await dal.get_group_users(
        req.group_id,
      );

      const tran = kv.atomic();

      const attendance_entity = await attendance_dal.get_attendance_entity(
        req.group_id,
        group.value.current_attendance_id,
      );

      attendance_entity.value.end_time_utc = new Date();
      if (req.time_spoof_minute_offset != null) {
        attendance_entity.value.end_time_utc = date_add(
          attendance_entity.value.end_time_utc,
          "minute",
          req.time_spoof_minute_offset,
        );
      }

      attendance_dal.set_attendance_tran(attendance_entity, tran);

      group.value.current_attendance_id = null;

      dal.update_group_tran(group, tran);

      await DbErr.err_on_commit_async(tran.commit(), "Unable to stop attendance");

      // If no users were marked as present no need to disconnect websockets
      if (group_users.length <= 0) {
        return ctx.text("", HttpStatusCode.OK);
      }

      // Get all rooms for the users and disconnect sockets
      const rooms = [];
      for (let i = 0; i < group_users.length; i++) {
        rooms.push(`${req.group_id}:${group_users[i].value.user_id}`);
      }
      ws.in(rooms).disconnectSockets(true);
    }

    // Do not allow the manager to edit any details about the group
    if (user_type === UserType.Manager) {
      return ctx.text("", HttpStatusCode.OK);
    }

    const group_entity = await dal.get_group(req.group_id);

    group_entity.value.group_name = req.group_name;
    group_entity.value.group_description = req.group_description;

    await dal.update_group(group_entity);

    return ctx.text("", HttpStatusCode.OK);
  },
);

//#endregion

export { group };
