import { Uuid } from "../../util/uuid.ts";

export interface GroupSparseGetModel {
  group_name: string;
  group_id: Uuid;
  group_description: string | null;
  owner_username: string;
  owner_id: Uuid;
}
