import { Match } from "effect";
import { GroupEntity, UniqueIdSettings } from "../entities/group_entity.ts";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import { GroupListGetRes } from "../models/group/group_list_res.ts";
import { GroupSparseGetModel } from "../models/group/group_sparse_get_model.ts";
import kv, { DbErr, KvHelper } from "./db.ts";
import { new_uuid, Uuid } from "../util/uuid.ts";
import AccountEntity, { AccountOwnerGroupData } from "../entities/account_entity.ts";
import { get_account, get_accounts, get_accounts_by_usernames } from "./account.ts";
import HttpStatusCode from "../util/http_status_code.ts";
import { add_to_maybe_map, add_to_maybe_set } from "../util/map.ts";
import { UserType } from "../models/user_type.ts";

//#region Query

/**
 * @description Gets a list of groups that the user owns, manages, and is a member of.
 * @param user_id - User id to retrieve groups for
 * @returns List of owned groups, managed groups, and member groups
 */
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
  const member_groups_promise = KvHelper.remove_kv_nones_async(
    KvHelper.get_many_return_empty<GroupEntity[]>(
      kv,
      KvHelper.map_to_kvs("group", account_entity.fk_member_group_ids),
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
    (await get_accounts(
      unique_user_ids
        .entries()
        .map((x) => x[0])
        .toArray(),
    )).map((x) => [x.value.user_id, x.value.username]),
  );

  // Convert all the retrieve data to an API model
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
    member_groups: to_sparse_model(groups[2]),
  } as GroupListGetRes;
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

/**
 * @description Verify the type of a user and get the associated group for that user
 * @param group_id - The id of the group to retrieve
 * @param user_id - The user id to check with
 * @param user_type_claim - The type of user the caller is claiming for the given group, if multiple are given
 * the function will verify that the user satisfies any claim
 * @throw {@link HTTPException} If the user claim does not agree with the what is stored in the DB
 */
export async function get_group_and_verify_user_type(
  group_id: Uuid,
  user_id: Uuid,
  user_type_claim: UserType | UserType[],
): Promise<GroupEntity | never> {
  const group = (await get_group(group_id)).value;
  let has_match = false;
  const matches_user_claim = (claim: UserType) =>
    Match.value(claim).pipe(
      Match.when(UserType.Owner, (_) => group.owner_id === user_id),
      Match.when(
        UserType.Manager,
        (_) => group.manager_ids?.has(user_id) ?? false,
      ),
      Match.when(UserType.Member, (_) => group.member_ids?.has(user_id) ?? false),
      Match.exhaustive,
    );

  if (Array.isArray(user_type_claim)) {
    has_match = user_type_claim.some((x) => matches_user_claim(x));
  } else {
    has_match = matches_user_claim(user_type_claim);
  }

  if (has_match) {
    return group;
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
 * @returns The id of the created
 * @throws @link{@ HTTPException}
 */
export async function create_group(owner_id: Uuid, req: GroupPostReq) {
  const entity = {
    group_id: new_uuid(),
    owner_id: owner_id,
    group_description: req.group_description,
    group_name: req.group_name,
    unique_id_settings: req.unique_id_settings,
    event_count: 0,
    manager_ids: null,
    member_ids: null,
    pending_member_ids: null,
    current_attendance_id: null,
  } as GroupEntity;

  const account_entity = await get_account(owner_id);

  account_entity.fk_owned_group_ids = add_to_maybe_map(
    account_entity.fk_owned_group_ids,
    [[entity.group_id, {} as AccountOwnerGroupData]],
    HttpStatusCode.INTERNAL_SERVER_ERROR,
    () => "bad generated id",
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
  tran: Deno.AtomicOperation,
  owner_id: Uuid,
  group_id: Uuid,
  invitees_usernames: string[],
) {
  // Ensure the specified users owns this account
  const owner_entity = await get_account(owner_id);
  group_is_owned_by_account(owner_entity, group_id);

  const [account_entities, group_entity] = await Promise.all(
    [get_accounts_by_usernames(invitees_usernames), get_group(group_id)],
  );

  group_entity.value.pending_member_ids = add_to_maybe_set(
    group_entity.value.pending_member_ids,
    account_entities.map((x) => x.value.user_id),
    HttpStatusCode.CONFLICT,
    (k) =>
      `Attempted to invite user '${account_entities.find((x) => x.value.user_id === k) ?? "N/A"}'`,
  );

  tran.set(["group", group_id], group_entity.value);

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
  tran: Deno.AtomicOperation,
  user_id: Uuid,
  group_id: Uuid,
  accept: boolean,
  is_manager_invite: boolean,
  unique_id: string | null = null,
) {
  const group_entity = (await get_group(group_id)).value;

  // Validate unique id if unique ids are enabled for this group
  if (group_entity.unique_id_settings !== null) {
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
      );
    }
  }

  if (!group_entity.pending_member_ids?.delete(user_id)) {
    DbErr.err("Invite not found", HttpStatusCode.CONFLICT);
  }

  // Add the user to the group if they are acepting the invite
  if (accept && is_manager_invite) {
    group_entity.manager_ids = add_to_maybe_set(
      group_entity.manager_ids,
      [user_id],
      HttpStatusCode.CONFLICT,
      () => "User is already a manager",
    );
  } else if (accept) {
    group_entity.member_ids = add_to_maybe_set(
      group_entity.member_ids,
      [user_id],
      HttpStatusCode.CONFLICT,
      () => "User is already a member",
    );
  }

  tran
    .set(["group", group_id], group_entity);
}

export async function set_group(entity: GroupEntity, tran?: Deno.AtomicOperation) {
  const no_tran = tran === undefined;
  if (tran === undefined) {
    tran = kv.atomic();
  }
  tran.set(["group", entity.group_id], entity);
  if (no_tran) {
    await DbErr.err_on_commit_async(tran.commit(), "Unable to update group");
  }
  return tran;
}

//#endregion
