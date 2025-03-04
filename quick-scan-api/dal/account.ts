import kv, { DbErr } from "./db.ts";
import AccountEntity from "../entities/account_entity.ts";
import { newUuid, Uuid } from "../uuid.ts";
import { AccountPostReq } from "../models/account/account_post_req.ts";
import { AccountLoginPostReq } from "../models/account/account_login_post_req.ts";
import { Match } from "effect";
import HttpStatusCode from "../http_status_code.ts";
import { data_views_are_equal } from "../util/array_buffer.ts";
import AccountGetModel from "../models/account/account_get_model.ts";

function merge_password_and_salt(password: string, salt: Uint8Array) {
  // Put the UTF-8 char code points into an array
  const txt = new TextEncoder();
  const password_en = txt.encode(password);

  const password_salt = new Uint8Array(salt.length + password_en.length);
  password_salt.set(password_en);
  password_salt.set(salt, password_en.length);
  return password_salt;
}

function hash_password(password: string, salt: Uint8Array) {
  return crypto.subtle.digest(
    "SHA-512",
    merge_password_and_salt(password, salt),
  );
}

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
    user_id: newUuid(),
    fk_owned_group_ids: null,
    fk_managed_group_ids: null,
    fk_member_group_ids: null,
  };

  const pk = ["account", entity.user_id];
  // Attempt to insert the user with the hashed password
  DbErr.err_on_commit(
    await kv
      .atomic()
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

export function get_account(user_id: Uuid) {
  return DbErr.err_on_empty_val_async(
    kv.get<AccountEntity>(["account", user_id]),
    () => "Unable to find account",
    HttpStatusCode.NOT_FOUND,
  ); //!! throw
}

export async function get_account_model(user_id: Uuid) {
  const entity = await get_account(user_id);
  return {
    username: entity.username,
    email: entity.email,
    first_name: entity.first_name,
    last_name: entity.last_name,
    user_id: entity.user_id,
    fk_owned_group_ids: entity.fk_owned_group_ids,
    fk_managed_group_ids: entity.fk_managed_group_ids,
    fk_member_group_ids: entity.fk_member_group_ids,
    versionstamp: entity.versionstamp,
  } as AccountGetModel;
}

// Get the user account and check if the given password is valid
// If the user exists and the password is valid then an Ok value will be returned
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
