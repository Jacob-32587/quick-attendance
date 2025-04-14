import { HTTPException } from "@hono/hono/http-exception";
import { Match } from "effect";
import { decode, sign } from "npm:hono/jwt";
import { jwt_alg, jwt_secret } from "../endpoints/account.ts";
import AccountEntity, { AccountManagerGroupData } from "../entities/account_entity.ts";
import { AccountLoginPostReq } from "../models/account/account_login_post_req.ts";
import { AccountPostReq } from "../models/account/account_post_req.ts";
import { AccountPutReq } from "../models/account/account_put_req.ts";
import { PublicAccountGetModel } from "../models/account/public_account_get_model.ts";
import { GroupInviteJwtPayload } from "../models/group_invite_jwt_payload.ts";
import { is_privileged_user_type, UserType } from "../models/user_type.ts";
import { data_views_are_equal } from "../util/array_buffer.ts";
import HttpStatusCode from "../util/http_status_code.ts";
import { add_to_maybe_map } from "../util/map.ts";
import { new_uuid, Uuid } from "../util/uuid.ts";
import kv, { DbErr, KvHelper } from "./db.ts";
import { UniqueIdSettings } from "../models/group/group_post_req.ts";

/**
 * @param password - The string password to merge with the salt value
 * @param salt - Array of 8 bit integers to act as the salt for the password
 * @returns Password combined with the given salt, as an array of 8 bit integers
 */
function merge_password_and_salt(password: string, salt: Uint8Array) {
  // Put the UTF-8 char code points into an array
  const txt = new TextEncoder();
  const password_en = txt.encode(password);

  const password_salt = new Uint8Array(salt.length + password_en.length);
  password_salt.set(password_en);
  password_salt.set(salt, password_en.length);
  return password_salt;
}

/**
 * @param password - Password string that needs to be hashed
 * @param salt - Salt to add onto the password
 * @returns SHA512 hashed and salted password as an 8 bit integer array buffer
 */
function hash_password(password: string, salt: Uint8Array) {
  return crypto.subtle.digest(
    "SHA-512",
    merge_password_and_salt(password, salt),
  );
}

//#region Query

/**
 * @description Retrieves a user for the database by id
 * @param user_id - Id of the user
 * @returns Account entity
 * @throws {@link HTTPException} if no user with the given id could found
 */
export async function get_account(user_id: Uuid) {
  return await DbErr.err_on_empty_val_async(
    kv.get<AccountEntity>(["account", user_id]),
    () => "Unable to find account",
    HttpStatusCode.NOT_FOUND,
  ); //!! throw
}

/**
 * @description Retrieves multiple users from the database by id
 * @param user_ids - List of user ids
 * @returns Account entities
 * @throws {@link HTTPException} if any user with the given ids could not be found
 */
export async function get_accounts(user_ids: Uuid[]) {
  if (user_ids.length === 0) {
    return [];
  }
  const acc = DbErr.err_on_any_empty_vals(
    await KvHelper.get_many_return_empty<AccountEntity>(kv, user_ids.map((x) => ["account", x])),
    () => "Account not found",
    HttpStatusCode.NOT_FOUND,
  );
  return acc;
}

/**
 * @description Retrieves multiple users from the database by id
 * @param user_ids - List of user ids
 * @returns Account entities
 * @throws {@link HTTPException} if any user with the given ids could not be found
 */
export async function get_public_account_models(
  user_ids: Uuid[] | null | undefined,
  group_id?: Uuid,
): Promise<PublicAccountGetModel[]> {
  // Return nothing if given nothing
  if (user_ids === null || user_ids === undefined || user_ids.length === 0) {
    return [];
  }

  // Get the unique if the given user type is privileged
  const maybe_unique_id = (entity: AccountEntity, user_type: UserType | null) => {
    if (group_id === undefined || user_type == null) {
      return null;
    }
    if (is_privileged_user_type(user_type)) {
      let maybe_unique_id_setting = entity?.fk_member_group_ids?.get(group_id);
      if (maybe_unique_id_setting === undefined) {
        maybe_unique_id_setting = entity?.fk_managed_group_ids?.get(group_id);
      }
      return maybe_unique_id_setting?.unique_id ?? null;
    }
    return null;
  };

  return (await get_accounts(user_ids)).map(
    (x) => {
      const user_type = group_id != undefined ? determine_user_type(x.value, group_id) : null;
      return {
        username: x.value.username,
        first_name: x.value.first_name,
        last_name: x.value.last_name,
        user_id: x.value.user_id,
        unique_id: maybe_unique_id(x.value, user_type),
        user_type: user_type,
      };
    },
  );
}

/**
 * @description Find the user type of a given user entity for the group
 * @param entity - User entity
 * @param group_id - Group id to get the user type for
 */
export function determine_user_type(entity: AccountEntity, group_id: Uuid) {
  if (entity.fk_member_group_ids?.has(group_id)) {
    return UserType.Member;
  } else if (entity.fk_managed_group_ids?.has(group_id)) {
    return UserType.Manager;
  } else if (entity.fk_owned_group_ids?.has(group_id)) {
    return UserType.Owner;
  }
  DbErr.err("User does not belong to the group", HttpStatusCode.INTERNAL_SERVER_ERROR);
}

/**
 * @description Retrieves multiple users from the database by username
 * @param user_ids - List of usernames
 * @returns Account entities
 * @throws {@link HTTPException} if any user with the give usernames could not be found
 */
export async function get_accounts_by_usernames(user_names: string[]) {
  const account_keys = DbErr.err_on_any_empty_vals(
    await KvHelper.get_many_return_empty<[string, Uuid]>(
      kv,
      user_names.map((x) => ["account_by_username", x]),
    ),
    () => "A username was invalid",
    HttpStatusCode.NOT_FOUND,
  );
  return get_accounts(account_keys.map((x) => x.value[1]));
}

/**
 * @description Verify the login information matches what was set by the user initially.
 * @param account - Information needed to login the user
 * @returns Account entity associated with the given credentials
 * @throws {@link HTTPException}
 */
export async function login_account(account: AccountLoginPostReq) {
  // Lookup the user by the secondary key, error if no record is found
  const account_email_key = (await kv.get<[string, Uuid]>([
    "account_by_email",
    account.email,
  ])).value;

  if (account_email_key == null) {
    DbErr.err("User does not exist", HttpStatusCode.NOT_FOUND); //!! throw
  }

  // Lookup by the primary key, this should never error but still
  // handle the case if this data does not exist
  const entity = (await kv.get<AccountEntity>(account_email_key)).value;

  if (entity == null) {
    DbErr.err("Account deleted"); //!! throw
  }

  // Hash the given password and compare to the password in the database
  // return Ok if the records match
  const password_hash = await hash_password(account.password, entity.salt);
  return Match.value(
    data_views_are_equal(
      new DataView(password_hash),
      new DataView(entity.password),
    ),
  ).pipe(
    Match.when(true, (_) => entity),
    Match.when(false, (_) =>
      DbErr.err(
        "Incorrect Password",
        HttpStatusCode.UNAUTHORIZED,
      )), //!! throw
    Match.exhaustive,
  );
}

//#endregion

//#region Mutation
/**
 * @description Create an account entity with the given information, this route will
 * ensure that the user name or email is not already in use.
 * @param account - Information that will be used for entity insertion
 */
export async function create_account(account: AccountPostReq) {
  // Ensure the username is not already in use
  const maybe_account = await kv.getMany<[[string, Uuid], [string, Uuid]]>([[
    "account_by_username",
    account.username,
  ], [
    "account_by_email",
    account.email,
  ]]);

  if (maybe_account[0].value != null || maybe_account[1].value != null) {
    const msg = Match.value([
      maybe_account[0].value != null,
      maybe_account[1].value != null,
    ]).pipe(
      Match.when(
        [true, true],
        (_) => "Username and email taken",
      ),
      Match.when(
        [false, true],
        (_) => "Email taken",
      ),
      Match.when(
        [true, false],
        (_) => "Username taken",
      ),
      Match.orElse((_) => "Unable to create account"),
    );

    DbErr.err(msg, HttpStatusCode.CONFLICT); //!! throw
  }

  // Generate salt and hash password
  const salt = new Uint8Array(32);
  crypto.getRandomValues(salt);

  // Calculate the hash for the given password
  const password_hash = await hash_password(account.password, salt);

  const entity: AccountEntity = {
    username: account.username,
    email: account.email,
    password: password_hash,
    first_name: account.first_name,
    last_name: account.last_name,
    salt: salt,
    user_id: new_uuid(),
    fk_owned_group_ids: null,
    fk_managed_group_ids: null,
    fk_member_group_ids: null,
    fk_pending_group_invites: null,
  };

  const pk = ["account", entity.user_id];
  // Attempt to insert the user with the hashed password, atomically ensure
  // that all unique identifiers are valid
  DbErr.err_on_commit(
    await kv
      .atomic()
      .check({ key: ["account_by_username", entity.username], versionstamp: null })
      .check({ key: ["account_by_email", entity.username], versionstamp: null })
      .check({ key: ["account", entity.user_id], versionstamp: null })
      .set(
        pk,
        entity,
      )
      .set(
        ["account_by_username", entity.username],
        pk,
      )
      .set(
        ["account_by_email", entity.email],
        pk,
      )
      .commit(),
    "Unable to insert user",
  );
}

/**
 * @description Invite the list of users to the specified group. If any of
 * these users have a pending invite to the specified group the function will throw.
 * @param tran - Deno transaction the invite is occurring in
 * @param group_id - Id of the group users are being invited to
 * @param invitees_accounts - Account entities with associated invite JWTs
 * @throw {@link HTTPException}
 * If any user has already been invited, this function fails fast.
 */
export async function invite_accounts_to_group(
  group_id: Uuid,
  group_name: string,
  owner_id: Uuid,
  is_manager_invite: boolean,
  unique_id_settings: UniqueIdSettings | null,
  invitees_accounts: Deno.KvEntry<AccountEntity>[],
  tran: Deno.AtomicOperation,
) {
  for (let i = 0; i < invitees_accounts.length; i++) {
    invitees_accounts[i].value.fk_pending_group_invites = add_to_maybe_map(
      invitees_accounts[i].value.fk_pending_group_invites,
      [[
        group_id,
        await sign(
          {
            iss: "quick-attendance-api",
            sub: "group-invite",
            aud: "quick-attendance-client",
            username: invitees_accounts[i].value.username,
            group_name,
            user_id: invitees_accounts[i].value.user_id,
            owner_id,
            group_id,
            is_manager_invite,
            unique_id_settings: unique_id_settings,
          } as GroupInviteJwtPayload,
          jwt_secret,
          jwt_alg,
        ),
      ]],
      HttpStatusCode.CONFLICT,
      (_, v) =>
        `User ${(decode(v).payload?.username ??
          "unknown")} already invited to this group`,
    ); //!! throw
    update_account_tran(invitees_accounts[i], tran);
  }
}

export async function update_account_from_req(user_id: Uuid, req: AccountPutReq) {
  const account_entity = await get_account(user_id);
  const tran = kv.atomic();

  // If username or email is being updated ensure that these are not already being used
  if (account_entity.value.username !== req.username) {
    tran
      .check({ key: ["account_by_username", req.username], versionstamp: null })
      .set(["account_by_username", req.username], ["account", user_id])
      .delete(["account_by_username", account_entity.value.username]);
  }
  if (account_entity.value.email !== req.email) {
    tran
      .check({ key: ["account_by_email", req.email], versionstamp: null })
      .set(["account_by_email", req.email], ["account", user_id])
      .delete(["account_by_email", account_entity.value.email]);
  }

  account_entity.value.username = req.username;
  account_entity.value.email = req.email;
  account_entity.value.first_name = req.first_name;
  account_entity.value.last_name = req.last_name;

  DbErr.err_on_commit_async(
    tran
      .check({ key: ["account", user_id], versionstamp: account_entity.versionstamp })
      .set(["account", user_id], account_entity.value).commit(),
    "Unable to update account, username or email address is in use",
  );
  return account_entity;
}

export function update_account(entity: Deno.KvEntry<AccountEntity>) {
  return DbErr.err_on_commit_async(
    update_account_tran(entity, kv.atomic()).commit(),
    "Unable to update account",
    HttpStatusCode.CONFLICT,
  );
}

export function update_account_tran(
  kv_entity: Deno.KvEntry<AccountEntity>,
  tran: Deno.AtomicOperation,
) {
  const key = ["account", kv_entity.value.user_id];
  tran
    .check({ key: key, versionstamp: kv_entity.versionstamp })
    .set(key, kv_entity.value as AccountEntity);

  return tran;
}

export async function respond_to_group_invite(
  user_id: Uuid,
  group_id: Uuid,
  accept: boolean,
  is_manager_invite: boolean,
  unique_id: string | null,
  tran: Deno.AtomicOperation,
) {
  const entity = await get_account(user_id);

  if (!entity.value.fk_pending_group_invites?.delete(group_id)) {
    DbErr.err("Invite not found", HttpStatusCode.CONFLICT);
  }

  if (accept && is_manager_invite) {
    entity.value.fk_managed_group_ids = add_to_maybe_map(
      entity.value.fk_managed_group_ids,
      [[group_id, { unique_id: unique_id } as AccountManagerGroupData]],
      HttpStatusCode.CONFLICT,
      () => "User is already a manager for this group",
    );
  } else if (accept) {
    entity.value.fk_member_group_ids = add_to_maybe_map(
      entity.value.fk_member_group_ids,
      [[group_id, { unique_id: unique_id } as AccountManagerGroupData]],
      HttpStatusCode.CONFLICT,
      () => "User is already a member for this group",
    );
  }
  update_account_tran(entity, tran);
}

//#endregion
