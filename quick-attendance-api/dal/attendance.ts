import { AttendanceEntity } from "../entities/attendance_entity.ts";
import { AttendancePresentMemberEntity as AttendancePresentUserEntity } from "../entities/attendance_present_member_entity.ts";
import { GroupEntity } from "../entities/group_entity.ts";
import { get_week_num_of_month } from "../util/time.ts";
import { get_uuid_time, new_uuid, Uuid } from "../util/uuid.ts";
import kv, { DbErr, KvHelper } from "./db.ts";
import * as group_dal from "./group.ts";
import * as account_dal from "./account.ts";
import { ws } from "../main.ts";

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

export async function get_most_recent_attendance_entity(group_id: Uuid) {
  return (await KvHelper.kv_iter_to_array(
    kv.list<AttendanceEntity>({
      prefix: [
        "attendance",
        group_id,
      ],
    }, {
      reverse: true,
      limit: 1,
      batchSize: 1,
    }),
  )).at(0);
}

export function get_attendance_entities_for_week(
  group_id: Uuid,
  year: number,
  month: number,
  week: number,
) {
  return KvHelper.kv_iter_to_array(kv.list<AttendanceEntity>({
    prefix: [
      "attendance",
      group_id,
      year,
      month,
      week,
    ],
  }, { limit: 128, batchSize: 128 }));
}

export function get_attendances_present_user(
  group_id: Uuid,
  user_id: Uuid,
  attendance_ids: Uuid[],
) {
  return KvHelper.get_many_return_empty<AttendancePresentUserEntity>(
    kv,
    attendance_ids.map((x) => ["attendance_present_user", group_id, x, user_id]),
  );
}

export function get_attendance_present_users(
  group_id: Uuid,
  attendance_id: Uuid,
) {
  return KvHelper.kv_iter_to_array(kv.list<AttendancePresentUserEntity>({
    prefix: [
      "attendance_present_user",
      group_id,
      attendance_id,
    ],
  }, { limit: 128, batchSize: 128 }));
}
//#endregion

//#region Mutation
export function create_attendance(
  group_id: Uuid,
  group_kv_entity: Deno.KvEntry<GroupEntity>,
  time_spoof_minute_offset: number | null = null,
) {
  const tran = kv.atomic();
  const attendance_id = new_uuid(
    time_spoof_minute_offset ? Date.now() - (time_spoof_minute_offset * 60000) : undefined,
  );
  const time = get_uuid_time(attendance_id);

  group_kv_entity.value.current_attendance_id = attendance_id;
  group_kv_entity.value.event_count++;

  create_attendance_entity_tran(group_id, attendance_id, {
    group_id: group_id,
    year: time.getUTCFullYear(),
    month: time.getUTCMonth(),
    week: get_week_num_of_month(time),
    attendance_id: attendance_id,
    end_time_utc: null,
    present_member_ids: new Set(),
    codes_taken: new Map(),
    user_codes: new Map(),
  } as AttendanceEntity, tran);

  group_dal.update_group_tran(group_kv_entity, tran);
  return DbErr.err_on_commit_async(tran.commit(), "Unable to create attendance record");
}

export function set_attendance_tran(
  entity: Deno.KvEntry<AttendanceEntity>,
  tran: Deno.AtomicOperation,
) {
  tran.check({ key: entity.key, versionstamp: entity.versionstamp }).set(entity.key, entity.value);
}

export function create_attendance_entity_tran(
  group_id: Uuid,
  attendance_id: Uuid,
  entity: AttendanceEntity,
  tran: Deno.AtomicOperation,
) {
  const key = [
    "attendance",
    group_id,
    entity.year,
    entity.month,
    entity.week,
    attendance_id,
  ];
  tran
    .check({ key: key, versionstamp: null })
    .set(key, entity);
}

export async function add_users_to_attendance(
  group_id: Uuid,
  user_ids: Uuid[],
) {
  const tran = kv.atomic();

  const current_attendance_id_p = group_dal.get_group(group_id);
  const group_users = await group_dal.get_group_users(group_id);
  const current_attendance_id = await current_attendance_id_p;
  const unique_user_ids = new Set(user_ids);
  // Only include user ids that belong to this group
  const filtered_user_ids = group_users.filter((x) => unique_user_ids.has(x.value.user_id));

  const present_users = filtered_user_ids.map(
    (x) => ({
      group_id: group_id,
      attendance_id: current_attendance_id.value.current_attendance_id,
      user_id: x.value.user_id,
    } as AttendancePresentUserEntity),
  );

  create_present_users_tran(present_users, tran);
  DbErr.err_on_commit(await tran.commit(), "Unable to save user attendance");

  // Notify users an attendance record has been created for them
  for (let i = 0; i < present_users.length; i++) {
    ws.to(`${group_id}:${present_users[i].user_id}`).emit("attendanceTaken");
  }
}

/**
 * @description This will set present users and ensure that no key
 * already exists.
 * @param entities - List of entites that represent present users
 * @returns Transaction that commands were added to
 */
export function create_present_users_tran(
  entities: AttendancePresentUserEntity[],
  tran: Deno.AtomicOperation,
) {
  for (let i = 0; i < entities.length; i++) {
    create_present_user_tran(
      {
        group_id: entities[i].group_id,
        attendance_id: entities[i].attendance_id,
        user_id: entities[i].user_id,
      } as AttendancePresentUserEntity,
      tran,
    );
  }
  return tran;
}

export function create_present_user_tran(
  entity: AttendancePresentUserEntity,
  tran: Deno.AtomicOperation,
) {
  const key = [
    "attendance_present_user",
    entity.group_id,
    entity.attendance_id,
    entity.user_id,
  ];
  tran
    .check({ key: key, versionstamp: null })
    .set(key, {
      group_id: entity.group_id,
      attendance_id: entity.attendance_id,
      user_id: entity.user_id,
    } as AttendancePresentUserEntity);
  return tran;
}

//#endregion
