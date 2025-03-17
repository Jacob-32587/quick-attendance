import { AttendanceEntity } from "../entities/attendance_entity.ts";
import { get_week_num_of_month } from "../util/time.ts";
import { get_uuid_time, new_uuid, Uuid } from "../util/uuid.ts";
import kv, { DbErr, KvHelper } from "./db.ts";
import * as group_dal from "./group.ts";

//#region Query
export async function get_attendance_entity(group_id: Uuid, attendance_id: Uuid) {
  const time = get_uuid_time(attendance_id);
  return await DbErr.err_on_empty_val_async(
    kv.get<AttendanceEntity>([
      "attendance",
      group_id,
      time.getUTCFullYear(),
      time.getUTCMonth(),
      get_week_num_of_month(time),
      attendance_id,
    ]),
    () =>
      `Unable to find attendance record with group_id = ${group_id}, attendance_id = ${attendance_id}`,
  );
}
export function get_attendance_entities_for_week(
  group_id: Uuid,
  year: number,
  month: number,
  week: number,
) {
  return kv.list<AttendanceEntity[]>({
    prefix: [
      "attendance",
      group_id,
      year,
      month,
      week,
    ],
  }, { limit: 8 });
}
//#endregion

//#region Mutation
export async function create_attendance_entity(group_id: Uuid) {
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
    get_week_num_of_month(time),
    attendance_id,
  ], {
    group_id: group_id,
    year: time.getUTCFullYear(),
    month: time.getUTCMonth(),
    week: get_week_num_of_month(time),
    attendance_id: attendance_id,
    present_member_ids: new Set(),
  } as AttendanceEntity);

  await group_dal.set_group(group_entity, tran);
  await DbErr.err_on_commit_async(tran.commit(), "Unable to begin attendance");
}

export async function set_attendance_entity(
  group_id: Uuid,
  attendance_id: Uuid,
  entity: AttendanceEntity,
  tran?: Deno.AtomicOperation,
) {
  const no_tran = tran === undefined;
  if (tran === undefined) {
    tran = kv.atomic();
  }
  tran.set([
    "attendance",
    group_id,
    entity.year,
    entity.month,
    entity.week,
    attendance_id,
  ], entity);
  if (no_tran) {
    await DbErr.err_on_commit_async(tran.commit(), "Unable to set attendance entity");
  }
}
//#endregion
