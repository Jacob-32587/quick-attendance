import { Uuid } from "../../uuid.ts";

export default interface AccountGetModel {
  username: string;
  first_name: string;
  last_name: string;
  user_id: Uuid;
  fk_owned_group_ids: Set<["group", Uuid]> | null;
  fk_member_group_ids: Set<["group", Uuid]> | null;
  versionstamp?: string;
}
