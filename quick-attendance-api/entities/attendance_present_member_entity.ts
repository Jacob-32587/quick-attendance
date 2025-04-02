import { Uuid } from "../util/uuid.ts";

export interface AttendancePresentMemberEntity {
  group_id: Uuid;
  attendance_id: Uuid;
  user_id: Uuid;
}
