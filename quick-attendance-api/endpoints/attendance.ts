import { Hono } from "npm:hono";
import * as dal from "../dal/attendance.ts";
import * as group_dal from "../dal/group.ts";
import { get_jwt_payload } from "../main.ts";
import { attendance_post_req } from "../models/attendance/attendance_post_req.ts";
import { zValidator } from "npm:@hono/zod-validator";
import { UserType } from "../models/user_type.ts";
import { attendance_put_req } from "../models/attendance/attendance_put_req.ts";

const attendance_base_path = "/attendance";
const auth_attendance_base_path = `/auth${attendance_base_path}`;

const attendance = new Hono();

//#region Query

//#endregion

//#region Mutation
attendance.post(auth_attendance_base_path, zValidator("json", attendance_post_req), async (ctx) => {
  const user_id = get_jwt_payload(ctx).user_id;
  const req = ctx.req.valid("json");
  const group_entity = await group_dal.get_group_and_verify_user_type(
    req.group_id,
    user_id,
    UserType.Owner,
  );
  await dal.create_attendance(req.group_id, group_entity);

  return ctx.text("");
});

attendance.put(auth_attendance_base_path, zValidator("json", attendance_put_req), async (ctx) => {
  const user_id = get_jwt_payload(ctx).user_id;
  const req = ctx.req.valid("json");
  // Verify the user is privileged
  const verify_user_promise = group_dal.get_group_and_verify_user_type(
    req.group_id,
    user_id,
    [UserType.Owner, UserType.Manager],
  );
  await verify_user_promise;

  // Attempt to save the current attendance record
  await dal.add_users_to_attendance(req.group_id, req.user_ids);

  return ctx.text("");
});
//#endregion

export { attendance };
