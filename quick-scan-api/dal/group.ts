import { Match } from "effect";
import { GroupEntity, UniqueIdSettings } from "../entities/group_entity.ts";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import kv, { DbErr } from "./db.ts";
import { newUuid, Uuid } from "../uuid.ts";
import AccountEntity, {
  AccountOwnerGroupData,
} from "../entities/account_entity.ts";
import HttpStatusCode from "../http_status_code.ts";

export async function create_group(owner_id: Uuid, req: GroupPostReq) {
  const entity = {
    group_id: newUuid(),
    owner_id: owner_id,
    group_description: req.group_description,
    group_name: req.group_name,
    unique_id_settings: Match.value(req.unique_id_settings).pipe(
      Match.when(Match.null, (_) => null),
      Match.orElse((s) => ({
        prompt_message: s.prompt_message,
        min_length: s.min_length,
        max_length: s.max_length,
        required_for_managers: s.required_for_managers,
      } as UniqueIdSettings)),
    ),
  } as GroupEntity;

  const account_entity = DbErr.err_on_empty_val(
    await kv.get<AccountEntity>(["account", owner_id]),
    () => "Account data does not exist",
    HttpStatusCode.NOT_FOUND,
  );

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

  kv
    .atomic()
    .set(["group", entity.group_id], entity)
    .set(["account", owner_id], account_entity)
    .commit();

  return entity;
}
