import { AttendanceEntity } from "../entities/attendance_entity.ts";
import { get_uuid_time, new_uuid, Uuid } from "../util/uuid.ts";
import { get_week_num } from "../util/week-num.ts";
import kv, { DbErr } from "./db.ts";
import * as group_dal from "./group.ts";

//#region Query
async function create_attendance_entity(group_id: Uuid) {
  const tran = kv.atomic();
  const attendance_id = new_uuid();
  const time = get_uuid_time(attendance_id);

  const group_entity = (await group_dal.get_group(group_id)).value;

  group_entity.current_attendance_id = attendance_id;

  tran.set([
    "attendance",
    group_id,
    time.getUTCFullYear(),
    time.getUTCMonth(),
    get_week_num(time),
    attendance_id,
  ], {
    group_id: group_id,
    year: time.getUTCFullYear(),
    month: time.getUTCMonth(),
    week: get_week_num(time),
    attendance_id: attendance_id,
    present_member_ids: new Set(),
  } as AttendanceEntity);

    group_dal.
}

async function update_attendance_entity(attendance_id: Uuid) {
}
//#endregion

//#region Mutation
//#endregion
