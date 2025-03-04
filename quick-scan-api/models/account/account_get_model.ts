import { Uuid } from "../../uuid.ts";

export default interface AccountGetModel {
  username: string;
  email: string;
  first_name: string;
  last_name: string | null;
  user_id: Uuid;
  fk_owned_group_ids: Set<["group", Uuid]> | null;
  fk_managed_group_ids: Set<["group", Uuid]> | null;
  fk_member_group_ids: Set<["group", Uuid]> | null;
  versionstamp?: string;
}
