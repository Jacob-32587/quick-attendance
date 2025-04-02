import { Uuid } from "../util/uuid.ts";

export interface GroupPendingUserEntity {
  group_id: Uuid;
  user_id: Uuid;
}
