import { Uuid } from "../../util/uuid.ts";
import { PublicAccountGetModel } from "../account/public_account_get_model.ts";

export interface AttendanceGroupGetRes {
  attendance: AttendanceGroupGetData[];
}

export interface AttendanceGroupGetData {
  attendance_id: Uuid;
  attendance_start_time: Date;
  attendance_end_time: Date | null;
  users: PublicAccountGetModel[];
}
