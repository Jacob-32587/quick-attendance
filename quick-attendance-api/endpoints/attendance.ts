import { Hono } from "npm:hono";
import * as dal from "../dal/attendance.ts";
import * as group_dal from "../dal/group.ts";
import { get_jwt_payload } from "../main.ts";
import { attendance_post_req } from "../models/attendance/attendance_post_req.ts";
import { zValidator } from "npm:@hono/zod-validator";
import { UserType } from "../models/user_type.ts";

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
  await dal.create_attendance_entity(req.group_id, group_entity);

  return ctx.text("");
});
//#endregion

export { attendance };
