import { Uuid } from "../util/uuid.ts";

export interface AttendanceEntity {
  group_id: Uuid;
  year: number;
  month: number;
  week: number;
  attendance_id: Uuid;
  end_time_utc: Date | null;
}
