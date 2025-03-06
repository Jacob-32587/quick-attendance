import { Match } from "effect";
import { GroupEntity, UniqueIdSettings } from "../entities/group_entity.ts";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import { GroupListGetRes } from "../models/group/group_list_res.ts";
import { GroupSparseGetModel } from "../models/group/group_sparse_get_model.ts";
import kv, { DbErr, KvHelper } from "./db.ts";
import { newUuid, Uuid } from "../uuid.ts";
import { AccountOwnerGroupData } from "../entities/account_entity.ts";
import { get_account, get_accounts } from "./account.ts";
import { HTTPException } from "@hono/hono/http-exception";
import HttpStatusCode from "../http_status_code.ts";

/**
 * @param owner_id - Id of the user who will own the created group
 * @param req -
 * @returns The id of the created
 * @throws @link{@ npm:Hono/}
 */
export async function create_group(owner_id: Uuid, req: GroupPostReq) {
  const entity = {
    group_id: newUuid(),
    owner_id: owner_id,
    group_description: req.group_description,
    group_name: req.group_name,
    unique_id_settings: req.unique_id_settings,
  } as GroupEntity;

  const account_entity = await get_account(owner_id);

  account_entity.fk_owned_group_ids = Match.value(
    account_entity.fk_owned_group_ids,
  )
    .pipe(
      Match.when(
        Match.null,
        (_) => new Map([[entity.group_id, {} as AccountOwnerGroupData]]),
      ),
      Match.orElse((m) =>
        Match.value(m.has(entity.group_id)).pipe(
          Match.when(true, (_) => DbErr.err("bad generated id")),
          Match.when(false, (_) =>
            m.set(entity.group_id, {} as AccountOwnerGroupData)),
          Match.exhaustive,
        )
      ),
    );

  await DbErr.err_on_commit_async(
    kv
      .atomic()
      .set(["group", entity.group_id], entity)
      .set(["account", owner_id], account_entity)
      .commit(),
    "Unable to perform mutation",
  ); //!! throw

  return entity;
}

export async function get_groups_for_account(user_id: Uuid) {
  const account_entity = await get_account(user_id); //!! throw

  // Get groups associated with this account
  const owned_groups_promise = KvHelper.remove_kv_nones_async(
    KvHelper.get_many_return_empty<GroupEntity[]>(
      kv,
      KvHelper.map_to_kvs("group", account_entity.fk_owned_group_ids),
    ),
  );
  const managed_groups_promise = KvHelper.remove_kv_nones_async(
    KvHelper.get_many_return_empty<GroupEntity[]>(
      kv,
      KvHelper.map_to_kvs("group", account_entity.fk_managed_group_ids),
    ),
  );
  const memeber_groups_promise = KvHelper.remove_kv_nones_async(
    KvHelper.get_many_return_empty<GroupEntity[]>(
      kv,
      KvHelper.map_to_kvs("group", account_entity.fk_member_group_ids),
    ),
  );

  // Wait for groups to be retrieved and get the unique group owner ids
  const groups = await Promise.all([
    owned_groups_promise,
    managed_groups_promise,
    memeber_groups_promise,
  ]);

  const unique_user_ids = new Set<Uuid>();

  for (let i = 0; i < groups.length; i++) {
    for (let k = 0; k < groups[i].length; k++) {
      unique_user_ids.add(groups[i][k].value.owner_id);
    }
  }

  const unique_owner_ids = new Map(
    (await get_accounts(
      unique_user_ids
        .entries()
        .map((x) => x[0])
        .toArray(),
    )).map((x) => [x.value.user_id, x.value.username]),
  );

  const to_sparse_model = (e: Deno.KvEntry<GroupEntity>[]) => {
    return e.map((x) => (
      {
        group_name: x.value.group_name,
        group_id: x.value.group_id,
        group_description: x.value.group_description,
        owner_id: x.value.owner_id,
        owner_username: unique_owner_ids.get(x.value.owner_id) ??
          DbErr.err(null),
      } as GroupSparseGetModel
    ));
  };

  return {
    owned_groups: to_sparse_model(groups[0]),
    managed_groups: to_sparse_model(groups[1]),
    memeber_groups: to_sparse_model(groups[2]),
  } as GroupListGetRes;
}
