import { Match } from "effect";
import { GroupEntity, UniqueIdSettings } from "../entities/group_entity.ts";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import kv, { DbErr } from "./db.ts";
import { newUuid, Uuid } from "../uuid.ts";
import AccountEntity, {
  AccountOwnerGroupData,
} from "../entities/account_entity.ts";
import HttpStatusCode from "../http_status_code.ts";
import { get_account } from "./account.ts";

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
      Match.orElse((s) =>
        Match.value(s.has(entity.group_id)).pipe(
          Match.when(true, (_) => DbErr.err("bad generated id")),
          Match.when(false, (_) =>
            s.set(entity.group_id, {} as AccountOwnerGroupData)),
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
  let group_promises: Promise<GroupEntity>[] =
    kv.getMany(
      account_entity.fk_owned_group_ids?.entries().map((x) => ["group", x[0]])
        .toArray(),
    ) ?? [];
}
