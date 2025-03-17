import { Hono } from "npm:hono";
import * as dal from "../dal/attendance.ts";
import * as group_dal from "../dal/group.ts";
import { get_jwt_payload } from "../main.ts";

const attendance_base_path = "/attendance";
const auth_attendance_base_path = `/auth${attendance_base_path}`;

const attendance = new Hono();

//#region Query

//#endregion

//#region Mutation
attendance.post(auth_attendance_base_path, async (ctx) => {
  const user_id = get_jwt_payload(ctx).user_id;

  return ctx.text("");
});
//#endregion

export { attendance };
