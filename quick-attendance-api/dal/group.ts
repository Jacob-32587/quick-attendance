import { Match } from "effect";
import { GroupEntity, UniqueIdSettings } from "../entities/group_entity.ts";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import { GroupListGetRes } from "../models/group/group_list_res.ts";
import { GroupSparseGetModel } from "../models/group/group_sparse_get_model.ts";
import kv, { DbErr, KvHelper } from "./db.ts";
import { new_uuid, Uuid } from "../util/uuid.ts";
import AccountEntity, { AccountOwnerGroupData } from "../entities/account_entity.ts";
import * as account_dal from "./account.ts";
import HttpStatusCode from "../util/http_status_code.ts";
import { add_to_maybe_map } from "../util/map.ts";
import { UserType } from "../models/user_type.ts";
import { GroupUserEntity } from "../entities/group_user_entity.ts";
import { GroupPendingUserEntity } from "../entities/group_pending_user_entity.ts";
import { HTTPException } from "@hono/hono/http-exception";

//#region Query

/**
 * @description Gets a list of groups that the user owns, manages, and is a member of.
 * @param user_id - User id to retrieve groups for
 * @returns List of owned groups, managed groups, and member groups
 */
export async function get_groups_for_account(user_id: Uuid) {
  const account_entity = await account_dal.get_account(user_id); //!! throw

  // Get groups associated with this account
  const owned_groups_promise = KvHelper.remove_kv_nones_async(
    KvHelper.get_many_return_empty<GroupEntity>(
      kv,
      KvHelper.map_to_kvs("group", account_entity.value.fk_owned_group_ids),
    ),
  );
  const managed_groups_promise = KvHelper.remove_kv_nones_async(
    KvHelper.get_many_return_empty<GroupEntity>(
      kv,
      KvHelper.map_to_kvs("group", account_entity.value.fk_managed_group_ids),
    ),
  );
  const member_groups_promise = KvHelper.remove_kv_nones_async(
    KvHelper.get_many_return_empty<GroupEntity>(
      kv,
      KvHelper.map_to_kvs("group", account_entity.value.fk_member_group_ids),
    ),
  );

  // Wait for groups to be retrieved and get the unique group owner ids
  const groups = await Promise.all([
    owned_groups_promise,
    managed_groups_promise,
    member_groups_promise,
  ]);

  // Collect the unique owner id's here, this is to prevent the extra
  // cost associated with grabbing duplicate data
  const unique_user_ids = new Set<Uuid>();

  for (let i = 0; i < groups.length; i++) {
    for (let k = 0; k < groups[i].length; k++) {
      unique_user_ids.add(groups[i][k].value.owner_id);
    }
  }

  const unique_owner_ids = new Map(
    (await account_dal.get_accounts(
      unique_user_ids
        .entries()
        .map((x) => x[0])
        .toArray(),
    )).map((x) => [x.value.user_id, x.value.username]),
  );

  // Convert all the retrieve data to an API model
  const to_sparse_model = (e: Deno.KvEntry<GroupEntity>[]) => {
    const sparse_models: GroupSparseGetModel[] = e.map((x) => (
      {
        group_name: x.value.group_name,
        group_id: x.value.group_id,
        group_description: x.value.group_description,
        owner_id: x.value.owner_id,
        owner_username: unique_owner_ids.get(x.value.owner_id) ??
          DbErr.err(null),
      }
    ));
    return sparse_models;
  };

  const res: GroupListGetRes = {
    owned_groups: to_sparse_model(groups[0]),
    managed_groups: to_sparse_model(groups[1]),
    member_groups: to_sparse_model(groups[2]),
  };
  return res;
}

/**
 * @description Get a group entity for the database with the given key
 * @param group_id - Group id to retrieve
 * @returns Group entity associated with the given id
 * @throw {@link HttpStatusCode} if the group was not found
 */
export async function get_group(group_id: Uuid) {
  return await DbErr.err_on_empty_val_async(
    kv.get<GroupEntity>(["group", group_id]),
    () => "Group does not exist",
    HttpStatusCode.NOT_FOUND,
  );
}

export function get_group_users(group_id: Uuid) {
  return KvHelper.kv_iter_to_array(kv.list<GroupUserEntity>({ prefix: ["group_user", group_id] }, {
    limit: 128,
    batchSize: 128,
  }));
}

export function get_group_user(group_id: Uuid, user_id: Uuid) {
  return DbErr.err_on_empty_val_async(
    kv.get<GroupUserEntity>(["group_user", group_id, user_id]),
    () => "User does not exist in group",
    HttpStatusCode.NOT_FOUND,
  );
}

export function add_group_users_tran(
  group_id: Uuid,
  user_id: Uuid[],
  user_type: UserType,
  tran: Deno.AtomicOperation,
) {
  for (let i = 0; i < user_id.length; i++) {
    tran.set(
      ["group_user", group_id, user_id[i]],
      { group_id: group_id, user_id: user_id[i], user_type: user_type } as GroupUserEntity,
    );
  }
  return tran;
}

export function add_pending_group_users(
  group_id: Uuid,
  user_ids: Uuid[],
) {
  return DbErr.err_on_commit_async(
    add_pending_group_users_tran(group_id, user_ids, kv.atomic()).commit(),
    "Unable to add user(s) to group",
    HttpStatusCode.CONFLICT,
  ); // !!throw
}

/**
 * @description Add a list of pending users to a group, the transaction will fail if any of the users are already part
 * of the group or any of the users are already invited
 */
export function add_pending_group_users_tran(
  group_id: Uuid,
  user_ids: Uuid[],
  tran: Deno.AtomicOperation,
) {
  let key;
  for (let i = 0; i < user_ids.length; i++) {
    key = ["group_pending_user", group_id, user_ids[i]];
    tran
      .check({ key: key, versionstamp: null })
      .check({ key: ["group_user", group_id, user_ids[i]], versionstamp: null })
      .set(key, { group_id: group_id, user_id: user_ids[i] } as GroupPendingUserEntity);
  }
  return tran;
}

export function get_group_pending_users(group_id: Uuid) {
  return KvHelper.kv_iter_to_array(
    kv.list<GroupPendingUserEntity>({ prefix: ["group_pending_user", group_id] }, {
      limit: 128,
      batchSize: 128,
    }),
  );
}

export function get_group_pending_user(group_id: Uuid, user_id: Uuid) {
  return DbErr.err_on_empty_val_async(
    kv.get<GroupPendingUserEntity>(["group_pending_user", group_id, user_id]),
    () => "Pending user does not exist for this group",
    HttpStatusCode.NOT_FOUND,
  ); // !!throw
}

export function delete_group_pending_users(
  group_id: Uuid,
  user_ids: Uuid[],
) {
  return DbErr.err_on_commit_async(
    delete_group_pending_users_tran(group_id, user_ids, kv.atomic()).commit(),
    "Unable to delete user from group, not found",
    HttpStatusCode.NOT_FOUND,
  ); // !!throw
}

export function delete_group_pending_users_tran(
  group_id: Uuid,
  user_ids: Uuid[],
  tran: Deno.AtomicOperation,
) {
  for (let i = 0; i < user_ids.length; i++) {
    tran.delete(
      ["group_pending_user", group_id, user_ids[i]],
    );
  }
  return tran;
}

/**
 * @description Verify the type of a user and get the associated group for that user
 * @param group_id - The id of the group to retrieve
 * @param user_id - The user id to check with
 * @param user_type_claim - The type of user the caller is claiming for the given group
 * @throw {@link HTTPException} If the user claim does not agree with what is stored in the DB
 */
export async function get_group_and_verify_user_type(
  group_id: Uuid,
  user_id: Uuid,
  user_type_claim: UserType | UserType[],
): Promise<[Deno.KvEntry<GroupEntity>, UserType] | never> {
  const group = await get_group(group_id);
  if (
    (Array.isArray(user_type_claim) && user_type_claim.some((x) => x === UserType.Owner)) ||
    user_type_claim === UserType.Owner
  ) {
    if (user_id === group.value.owner_id) {
      return [group, UserType.Owner];
    }
  }

  const group_user = await get_group_user(group_id, user_id);

  if (
    Array.isArray(user_type_claim) === true
  ) {
    if (user_type_claim.some((x) => x === group_user.value.user_type)) {
      return [group, group_user.value.user_type];
    }
  } else if (user_type_claim === group_user.value.user_type) {
    return [group, group_user.value.user_type];
  }

  DbErr.err("Invalid user type claim for group", HttpStatusCode.FORBIDDEN); //!!throw
}

export function group_is_owned_by_account(
  account_entity: AccountEntity,
  group_id: Uuid,
) {
  Match.value(account_entity.fk_owned_group_ids?.has(group_id) ?? false).pipe(
    Match.when(true, () => true),
    Match.when(
      false,
      () => DbErr.err("User does not own the group", HttpStatusCode.FORBIDDEN),
    ),
  );
}
//#endregion

//#region Mutation
/**
 * @param owner_id - Id of the user who will own the created group
 * @param req -
 * @returns The id of the created group
 * @throws @link{@ HTTPException}
 */
export async function create_group_from_req(owner_id: Uuid, req: GroupPostReq) {
  const entity: GroupEntity = {
    group_id: new_uuid(),
    owner_id: owner_id,
    group_description: req.group_description,
    group_name: req.group_name,
    unique_id_settings: req.unique_id_settings,
    event_count: 0,
    current_attendance_id: null,
  };

  const account_entity = await account_dal.get_account(owner_id);

  account_entity.value.fk_owned_group_ids = add_to_maybe_map(
    account_entity.value.fk_owned_group_ids,
    [[entity.group_id, {} as AccountOwnerGroupData]],
    HttpStatusCode.INTERNAL_SERVER_ERROR,
    () => "bad generated id",
  );

  // Update accont and create group
  const tran = account_dal.update_account_tran(account_entity, kv.atomic());
  await DbErr.err_on_commit_async(
    create_group_tran(entity, tran).commit(),
    "Unable to perform mutation",
  ); //!! throw

  return entity;
}

export function create_group_tran(entity: GroupEntity, tran: Deno.AtomicOperation) {
  const key = ["group", entity.group_id];
  tran
    .check({ key: key, versionstamp: null })
    .set(key, entity);
  return tran;
}

/**
 * @description Verifies the specified owner id owns the group and that the
 * given user names exist. If checks are passed the group is updated with the
 * pending member ids.
 * @param tran - Transaction the group invite is being executed in
 * @param owner_id - The account id for the owner of the group
 * @param group_id - The group id users are being invited to
 * @param invitees_usernames - List of usernames to invite to the group
 * @returns Owner entity and account entities that are being invited
 */
export async function accounts_for_group_invite(
  owner_id: Uuid,
  group_id: Uuid,
  invitees_usernames: string[],
  tran: Deno.AtomicOperation,
) {
  // Ensure the specified users owns this account
  const owner_entity = await account_dal.get_account(owner_id);
  group_is_owned_by_account(owner_entity.value, group_id);

  const account_entities = await account_dal.get_accounts_by_usernames(invitees_usernames);

  if (account_entities.some((x) => x.value.user_id === owner_id)) {
    throw new HTTPException(
      HttpStatusCode.CONFLICT,
      { message: "Can not invite the group owner to the group" },
    );
  }

  add_pending_group_users_tran(group_id, account_entities.map((x) => x.value.user_id), tran);

  return { owner_entity, account_entities };
}

/**
 * @description Verifies that the provided unique id matches the requirements
 * specified by the group. If all checks are passed the user is either added to
 * the group of removed from the pending list, depending on the users action.
 * @param tran - Transaction the group invite respond is being executed in
 * @param group_id - The group id the user is being invited to
 * @param user_id - The id of the user taking action on the group invite
 * @param accept - If the user accepts the group invite
 * @param is_manager_invite - If the invite should add the user as a manager
 * @param unique_id - The unique id of the user, if one is needed
 */
export async function respond_to_group_invite(
  user_id: Uuid,
  group_id: Uuid,
  accept: boolean,
  is_manager_invite: boolean,
  unique_id: string | null = null,
  tran: Deno.AtomicOperation,
) {
  const group_entity = (await get_group(group_id)).value;

  // Validate unique id if unique ids are enabled for this group
  if (group_entity.unique_id_settings !== null && accept) {
    // Get message suffix based on the group settings
    let bad_unique_id_setting_message: string;
    if (
      group_entity.unique_id_settings.max_length ===
        group_entity.unique_id_settings.min_length
    ) {
      bad_unique_id_setting_message =
        `of exactly ${group_entity.unique_id_settings.max_length} character(s)`;
    } else {
      bad_unique_id_setting_message =
        `between ${group_entity.unique_id_settings.min_length} and ${group_entity.unique_id_settings.max_length} character(s)`;
    }

    if (
      unique_id === null ||
      unique_id.length < group_entity.unique_id_settings.min_length ||
      unique_id.length > group_entity.unique_id_settings.max_length
    ) {
      DbErr.err(
        `This group requires a unique id ${bad_unique_id_setting_message}`,
        HttpStatusCode.BAD_REQUEST,
      ); //!!throw
    }
  }

  await delete_group_pending_users(group_id, [user_id]);

  // Add the user to the group if they are accepting the invite
  if (accept && is_manager_invite) {
    add_group_users_tran(group_id, [user_id], UserType.Manager, tran);
  } else if (accept) {
    add_group_users_tran(group_id, [user_id], UserType.Member, tran);
  }
}

export async function update_group(kv_entity: Deno.KvEntry<GroupEntity>) {
  DbErr.err_on_commit(
    await update_group_tran(kv_entity, kv.atomic()).commit(),
    "Unable to update group",
    HttpStatusCode.CONFLICT,
  );
}

export function update_group_tran(
  kv_entity: Deno.KvEntry<GroupEntity>,
  tran: Deno.AtomicOperation,
) {
  const key = ["group", kv_entity.value.group_id];
  tran
    .check({ key: key, versionstamp: kv_entity.versionstamp })
    .set(key, kv_entity.value);
  return tran;
}

//#endregion
