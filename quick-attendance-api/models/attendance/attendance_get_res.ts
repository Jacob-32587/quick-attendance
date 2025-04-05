import { Uuid } from "../../util/uuid.ts";
import { PublicAccountGetModel } from "../account/public_account_get_model.ts";

export interface AttendanceGetRes {
  attendance: { attendance_id: Uuid; users: PublicAccountGetModel[] }[];
}
