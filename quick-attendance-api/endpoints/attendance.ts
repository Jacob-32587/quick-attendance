import { Hono } from "npm:hono";
import * as dal from "../dal/attendance.ts";
import * as group_dal from "../dal/group.ts";
import * as account_dal from "../dal/account.ts";
import { get_jwt_payload } from "../main.ts";
import { attendance_post_req } from "../models/attendance/attendance_post_req.ts";
import { zValidator } from "npm:@hono/zod-validator";
import { UserType } from "../models/user_type.ts";
import { attendance_put_req } from "../models/attendance/attendance_put_req.ts";
import { get_uuid_time, Uuid } from "../util/uuid.ts";
import { get_public_account_models } from "../dal/account.ts";
import { HTTPException } from "@hono/hono/http-exception";
import HttpStatusCode from "../util/http_status_code.ts";
import {
  AttendanceUserData,
  AttendanceUserGetRes,
} from "../models/attendance/attendance_user_get_res.ts";
import {
  AttendanceGroupGetData,
  AttendanceGroupGetRes,
} from "../models/attendance/attendance_group_get_res.ts";
import { attendance_group_get_req } from "../models/attendance/attedance_group_get_req.ts";
import { attendance_user_get_req } from "../models/attendance/attedance_user_get_req.ts";

const attendance_base_path = "/attendance";
const auth_attendance_base_path = `/auth${attendance_base_path}`;

const attendance = new Hono();

//#region Query
attendance.get(
  `${auth_attendance_base_path}/group`,
  zValidator("query", attendance_group_get_req),
  async (ctx) => {
    console.log(ctx);
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

    const attedance_agg: AttendanceGroupGetData[] = [];
    let current_user;
    for (let i = 0; i < attedance_records.length; i++) {
      attedance_agg.push({
        attendance_id: attedance_records[i].value.attendance_id,
        attendance_start_time: get_uuid_time(attedance_records[i].value.attendance_id),
        attendance_end_time: attedance_records[i].value.end_time_utc,
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

    const ret: AttendanceGroupGetRes = { attendance: attedance_agg };
    return ctx.json(ret);
  },
);

attendance.get(
  `${auth_attendance_base_path}/user`,
  zValidator("query", attendance_user_get_req),
  async (ctx) => {
    const user_id = get_jwt_payload(ctx).user_id;
    const req = ctx.req.valid("query");

    const account = await account_dal.get_account(user_id);
    const unique_group_ids = new Set(
      (account.value.fk_managed_group_ids
        ?.keys()
        .toArray() ?? [])
        .concat(account.value.fk_member_group_ids?.keys().toArray() ?? []),
    ).values().toArray();

    if (unique_group_ids.length === 0) {
      const ret: AttendanceGroupGetRes = { attendance: [] };
      ctx.json(ret);
    }

    const attendance_data: AttendanceUserData[] = [];
    for (const group_id of unique_group_ids) {
      // Get all attendance records for the given group
      const attendance_records = await dal.get_attendance_entities_for_week(
        group_id,
        req.year_num,
        req.month_num,
        req.week_num,
      );
      const attendance_record_lookup = new Map(
        attendance_records.map((x) => [x.value.attendance_id, x]),
      );
      const present_user_records = await dal.get_attendances_present_user(
        group_id,
        user_id,
        attendance_records.map((x) => x.value.attendance_id),
      );

      if (present_user_records.length <= 0) {
        continue;
      }

      const group = await group_dal.get_group(group_id);
      attendance_data.push(
        {
          group: {
            group_name: group.value.group_name,
            group_id: group_id,
          },
          attendance_records: present_user_records.map((x) => (
            {
              attendance_id: x.key[2] as Uuid,
              attendance_start_time: get_uuid_time(x.key[2] as Uuid),
              attendance_end_time:
                attendance_record_lookup.get(x.key[2] as Uuid)?.value.end_time_utc ?? null,
              present: x.value !== null,
            }
          )),
        },
      );
    }
    const ret: AttendanceUserGetRes = { attendance: attendance_data };
    return ctx.json(ret);
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

  await dal.create_attendance(req.group_id, group_entity, req.time_spoof_minute_offset);

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
