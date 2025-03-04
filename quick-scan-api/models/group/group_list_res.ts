import { GroupEntity } from "../../entities/group_entity.ts";

export interface GroupListRes {
  owned_groups: GroupEntity[] | null;
  managed_groups: GroupEntity[] | null;
  memeber_groups: GroupEntity[] | null;
}
