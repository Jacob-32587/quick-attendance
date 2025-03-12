import { Uuid } from "../../util/uuid.ts";

export default interface AccountGetModel {
  username: string;
  email: string;
  first_name: string;
  last_name: string | null;
  user_id: Uuid;
  fk_pending_group_ids: Set<Uuid> | null;
  versionstamp?: string;
}
