import { Uuid } from "../../util/uuid.ts";
import { UserType } from "../user_type.ts";

export interface PublicAccountGetModel {
  username: string;
  first_name: string;
  last_name: string | null;
  user_id: Uuid;
  unique_id: string | null;
  user_type: UserType | null;
}
