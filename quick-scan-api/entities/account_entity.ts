import { GroupInviteJwtPayload } from "../models/group/group_invite_jwt_payload.ts";
import { Uuid } from "../uuid.ts";

export default interface AccountEntity {
  username: string;
  email: string;
  first_name: string;
  last_name: string | null;
  password: ArrayBuffer;
  salt: Uint8Array;
  user_id: Uuid;
  fk_owned_group_ids: Map<Uuid, AccountOwnerGroupData> | null;
  fk_managed_group_ids: Map<Uuid, AccountManagerGroupData> | null;
  fk_member_group_ids: Map<Uuid, AccountMemberGroupData> | null;
  fk_pending_group_invites: Map<Uuid, string> | null;
  readonly versionstamp?: string;
}

export interface AccountOwnerGroupData {
  _: never;
}

export interface AccountManagerGroupData {
  unique_id: string;
}

export interface AccountMemberGroupData {
  unique_id: string;
}
