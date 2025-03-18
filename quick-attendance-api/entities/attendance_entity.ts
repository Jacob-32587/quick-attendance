import { Uuid } from "../util/uuid.ts";

export interface AttendanceEntity {
  group_id: Uuid;
  year: number;
  month: number;
  week: number;
  attendance_id: Uuid;
  present_member_ids: Set<Uuid>;
  // Used to guarantee that a unique code exists and associate
  // that code with a user
  codes_taken: Map<string, Uuid>;
  // Used to guarantee that a given user owns a single code
  user_codes: Map<Uuid, string>;
}
