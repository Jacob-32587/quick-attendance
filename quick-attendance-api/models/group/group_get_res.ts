import { Uuid } from "../../util/uuid.ts";
import PublicAccountGetModel from "../account/public_account_get_model.ts";

export interface GroupGetRes {
  group_id: Uuid;
  owner_id: PublicAccountGetModel;
  managers: PublicAccountGetModel[] | null;
  members: PublicAccountGetModel[] & { unique_id: Uuid } | null;
  pending_memebers: PublicAccountGetModel[] | null;
  group_name: string;
  group_description: string | null;
  current_attendance_id: Uuid | null;
  event_count: number;
}
