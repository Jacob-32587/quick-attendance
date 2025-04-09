import { Uuid } from "../../util/uuid.ts";

export interface AttendanceUserGetRes {
  attendance: AttendanceUserData[];
}

export interface AttendanceUserData {
  group: { group_id: Uuid; group_name: string };
  attendance_records: ({
    attendance_id: Uuid;
    attendance_time: Date;
    present: boolean;
  })[];
}
