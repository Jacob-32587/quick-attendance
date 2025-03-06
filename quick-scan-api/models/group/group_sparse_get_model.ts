import { Uuid } from "../../uuid.ts";

export interface GroupSparseGetModel {
  group_name: string;
  group_description: string;
  owner_username: string;
  owner_id: Uuid;
}
