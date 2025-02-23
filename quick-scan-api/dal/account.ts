import kv, { DbErr } from "./db.ts";
import AccountEntity from "../entities/account.ts";
import { newUuid, Uuid } from "../uuid.ts";
import { AccountPostReq } from "../models/account/account_post_req.ts";
import { Result } from "@result/result";
import HttpStatusCode from "../http_status_code.ts";
import { AccountLoginPostReq } from "../models/account/account_login_post_req.ts";
import { data_views_are_equal } from "../util/array_buffer.ts";

function merge_password_and_salt(password: string, salt: Uint8Array) {
  // Put the utf-8 char code points into an array
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
  const maybe_account = await kv.get<[string, Uuid]>([
    "account_by_user_name",
    account.username,
  ]);

  if (maybe_account.value != null) {
    return Result.err({
      reason: "Username taken",
      status_code: HttpStatusCode.CONFLICT,
    } as DbErr);
  }

  // Generate salt and hash password
  const salt = new Uint8Array(32);
  crypto.getRandomValues(salt);

  // Calculate the hash for the given password
  const password_hash = await hash_password(account.password, salt);

  const entity: AccountEntity = {
    username: account.username,
    password: password_hash,
    salt: salt,
    user_id: newUuid(),
    created_utc: (new Date()).toUTCString(),
  };

  const pk = ["account", entity.user_id];

  // Attempt to insert the user with the hashed password
  const res = await kv
    .atomic()
    .set(
      pk,
      entity,
    )
    .commit();
  const user_res = await kv.atomic()
    .set(
      ["account_by_user_name", entity.username],
      pk,
    )
    .commit();

  switch (res.ok) {
    // deno-lint-ignore no-fallthrough
    case true:
      switch (user_res.ok) {
        case true:
          return Result.ok(entity.user_id);
        case false:
          return Result.err({
            reason: "Unable to insert user secondary key",
            status_code: HttpStatusCode.INTERNAL_SERVER_ERROR,
          } as DbErr);
      }
    case false:
      return Result.err(
        {
          reason: "Unable to insert user",
          status_code: HttpStatusCode.INTERNAL_SERVER_ERROR,
        } as DbErr,
      );
  }
}

// Get the user account and check if the given password is valid
// If the user exists and the password is valid then an Ok value will be returned
export async function login_account(account: AccountLoginPostReq) {
  // Lookup the user by the secondary key, error if no record is found
  const user_name_key = await kv.get<[string, Uuid]>([
    "account_by_user_name",
    account.username,
  ]);

  if (user_name_key.value == null) {
    return Result.err(
      {
        reason: "User does not exist",
        status_code: HttpStatusCode.NOT_FOUND,
      } as DbErr,
    );
  }

  // Lookup by the primary key, this should never error but still
  // handle the case if this data does not exist
  const entity = (await kv.get<AccountEntity>(user_name_key.value)).value;

  if (entity == null) {
    return Result.err({
      reason: "User was found but no data associated with accoutn, missing pk",
      status_code: HttpStatusCode.INTERNAL_SERVER_ERROR,
    } as DbErr);
  }

  // Hash the given password and compare to the password in the database
  // return Ok if the records match
  const password_hash = await hash_password(account.password, entity.salt);
  switch (
    data_views_are_equal(
      new DataView(password_hash),
      new DataView(entity.password),
    )
  ) {
    case true:
      return Result.ok(entity);
    case false:
      return Result.err({
        reason: "Incorrect Password",
        status_code: HttpStatusCode.UNAUTHORIZED,
      } as DbErr);
  }
}
