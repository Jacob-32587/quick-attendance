import { Uuid } from "../../util/uuid.ts";

export interface PublicAccountGetModel {
  username: string;
  first_name: string;
  last_name: string | null;
  user_id: Uuid;
}
