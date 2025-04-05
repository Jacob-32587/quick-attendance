import { UserType } from "../models/user_type.ts";
import { Uuid } from "../util/uuid.ts";

export interface GroupUserEntity {
  group_id: Uuid;
  user_id: Uuid;
  user_type: UserType;
}
