import { Hono } from "npm:hono";
import * as dal from "../dal/attendance.ts";
import * as group_dal from "../dal/group.ts";
import { get_jwt_payload } from "../main.ts";
import { attendance_post_req } from "../models/attendance/attendance_post_req.ts";
import { zValidator } from "npm:@hono/zod-validator";
import { is_privileged_user_type, UserType } from "../models/user_type.ts";
import { attendance_put_req } from "../models/attendance/attendance_put_req.ts";
import { attendance_get_req } from "../models/attendance/attedance_get_req.ts";
import { get_uuid_time, Uuid } from "../util/uuid.ts";
import { AttendanceGetRes } from "../models/attendance/attendance_get_res.ts";
import { get_public_account_models } from "../dal/account.ts";
import { PublicAccountGetModel } from "../models/account/public_account_get_model.ts";
import { HTTPException } from "@hono/hono/http-exception";
import HttpStatusCode from "../util/http_status_code.ts";

const attendance_base_path = "/attendance";
const auth_attendance_base_path = `/auth${attendance_base_path}`;

const attendance = new Hono();

//#region Query
attendance.get(
  `${auth_attendance_base_path}/group`,
  zValidator("query", attendance_get_req),
  async (ctx) => {
    const user_id = get_jwt_payload(ctx).user_id;
    const req = ctx.req.valid("query");

    // Ensure that the user is privileged
    await group_dal.get_group_and_verify_user_type(
      req.group_id,
      user_id,
      [
        UserType.Owner,
        UserType.Manager,
      ],
    );

    const attedance_records = await dal.get_attendance_entities_for_week(
      req.group_id,
      req.year_num,
      req.month_num,
      req.week_num,
    );

    const group_user_ids = (await group_dal.get_group_users(req.group_id)).map((x) =>
      x.value.user_id
    );

    const group_users = new Map(
      (await get_public_account_models(group_user_ids, req.group_id)).map((x) => [x.user_id, x]),
    );

    const attedance_agg: {
      attendance_id: Uuid;
      time_recorded: Date;
      users: PublicAccountGetModel[];
    }[] = [];
    let current_user;
    for (let i = 0; i < attedance_records.length; i++) {
      attedance_agg.push({
        attendance_id: attedance_records[i].value.attendance_id,
        time_recorded: get_uuid_time(attedance_records[i].value.attendance_id),
        users: [],
      });

      for (
        const user of await dal.get_attendance_present_users(
          req.group_id,
          attedance_records[i].value.attendance_id,
        )
      ) {
        current_user = group_users.get(user.value.user_id);
        // This should never happen
        if (current_user === undefined) {
          throw new HTTPException(HttpStatusCode.NOT_FOUND);
        }
        attedance_agg[i].users.push(current_user);
      }
    }

    const ret: AttendanceGetRes = { attendance: attedance_agg };
    return ctx.json(ret);
  },
);

attendance.get(
  `${auth_attendance_base_path}/user`,
  zValidator("query", attendance_get_req),
  async (ctx) => {
    const user_id = get_jwt_payload(ctx).user_id;
    const req = ctx.req.valid("query");

    // Ensure that the user is privileged
    await group_dal.get_group_and_verify_user_type(
      req.group_id,
      user_id,
      [
        UserType.Manager,
        UserType.Owner,
      ],
    );
  },
);
//#endregion

//#region Mutation
attendance.post(auth_attendance_base_path, zValidator("json", attendance_post_req), async (ctx) => {
  const user_id = get_jwt_payload(ctx).user_id;
  const req = ctx.req.valid("json");
  const [group_entity, _] = await group_dal.get_group_and_verify_user_type(
    req.group_id,
    user_id,
    [UserType.Owner, UserType.Manager],
  );

  await dal.create_attendance(req.group_id, group_entity);

  return ctx.text("");
});

attendance.put(auth_attendance_base_path, zValidator("json", attendance_put_req), async (ctx) => {
  const user_id = get_jwt_payload(ctx).user_id;
  const req = ctx.req.valid("json");
  // Verify the user is privileged
  await group_dal.get_group_and_verify_user_type(
    req.group_id,
    user_id,
    [UserType.Owner, UserType.Manager],
  );

  // Attempt to save the current attendance record
  await dal.add_users_to_attendance(req.group_id, req.user_ids);

  return ctx.text("");
});
//#endregion

export { attendance };
