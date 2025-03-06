import { GroupSparseGetModel } from "./group_sparse_get_model.ts";

export interface GroupListGetRes {
  owned_groups: GroupSparseGetModel[];
  managed_groups: GroupSparseGetModel[];
  memeber_groups: GroupSparseGetModel[];
}
