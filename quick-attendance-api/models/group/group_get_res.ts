import { Uuid } from "../../util/uuid.ts";
import { PublicAccountGetModel } from "../account/public_account_get_model.ts";

export interface GroupGetRes {
  group_id: Uuid;
  owner: PublicAccountGetModel;
  managers: PublicAccountGetModel[] | null;
  members: PublicAccountGetModel[] | null;
  pending_members: PublicAccountGetModel[] | null;
  group_name: string;
  group_description: string | null;
  current_attendance_id: Uuid | null;
  last_attendance_date: Date | null;
  event_count: number;
}
