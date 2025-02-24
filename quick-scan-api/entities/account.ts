import { Uuid } from "../uuid.ts";

export default interface AccountEntity {
  username: string;
  password: ArrayBuffer;
  salt: Uint8Array;
  user_id: Uuid;
  created_utc: string;
}
