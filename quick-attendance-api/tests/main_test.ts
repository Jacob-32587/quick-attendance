import { AccountPostReq } from "../models/account/account_post_req.ts";
import { AccountLoginPostRes } from "../models/account/account_login_post_res.ts";
import { AccountLoginPostReq } from "../models/account/account_login_post_req.ts";
import { assertNever, test_fetch } from "../util/testing.ts";
import { Uuid } from "../util/uuid.ts";
import AccountGetModel from "../models/account/account_get_model.ts";

export const URL = (n: number) =>
  `http://0.0.0.0:${8080 + n}/quick-attendance-api`;
export const ACCOUNT_URL = (n: number) => `${URL(n)}/account`;
export const ACCOUNT_AUTH_URL = (n: number) => `${URL(n)}/auth/account`;
export const GROUP_URL = (n: number) => `${URL(n)}/group`;
export const GROUP_AUTH_URL = (n: number) => `${URL(n)}/auth/group`;

export const user_rocco_mason = {
  "username": "Rocco Mason",
  "email": "rocco243@bar.com",
  "first_name": "Rocco",
  "last_name": "Mason",
  "password": "rocco_is_cool",
} as AccountPostReq;

export const user_maeve_berg = {
  "username": "Maeve Berg",
  "email": "maeve_b@bar.com",
  "first_name": "Maeve",
  "last_name": "B",
  "password": "lovely_puppy_992",
} as AccountPostReq;

export const user_henrik_wright = {
  "username": "Henrik Wright",
  "email": "henrik@baz.org",
  "first_name": "Henrik",
  "password": "long-passwords-are-cool-482-260-8822",
} as AccountPostReq;

export const user_indie_conway = {
  "username": "Indie Conway",
  "email": "indieC@fun.com",
  "first_name": "Indie",
  "last_name": "Conway",
  "password": "conway_indie_2001",
} as AccountPostReq;

export const user_array = [
  user_rocco_mason,
  user_maeve_berg,
  user_henrik_wright,
  user_indie_conway,
];

export async function create_and_login_test_users(test_num: number) {
  const create_user_promises: Promise<Response>[] = [];
  // Create test user accounts
  for (const user of user_array) {
    create_user_promises.push(
      test_fetch(ACCOUNT_URL(test_num), {
        headers: {
          "content-type": "application/json",
        },
        method: "POST",
        body: JSON.stringify(user),
      }),
    );
  }

  await Promise.all(create_user_promises);

  // Login users
  const login_user_promises: Promise<Response>[] = [];
  const user_jwts = new Map<string, string>();
  for (const user of user_array) {
    login_user_promises.push(
      test_fetch(ACCOUNT_URL(test_num) + "/login", {
        headers: {
          "content-type": "application/json",
        },
        method: "POST",
        body: JSON.stringify(
          {
            email: user.email,
            password: user.password,
          } as AccountLoginPostReq,
        ),
      }, async (res, req) => {
        const request = JSON.parse(
          req?.body?.toString() ?? "{}",
        ) as AccountLoginPostReq;

        const jwt = ((await res.json()) as AccountLoginPostRes).jwt;

        user_jwts.set(request.email, jwt);

        return (jwt !== null || jwt !== undefined);
      }),
    );
  }

  await Promise.all(login_user_promises);

  return [
    user_jwts.get(user_rocco_mason.email) ?? assertNever(),
    user_jwts.get(user_maeve_berg.email) ?? assertNever(),
    user_jwts.get(user_henrik_wright.email) ?? assertNever(),
    user_jwts.get(user_indie_conway.email) ?? assertNever(),
  ];
}

export async function get_user_accounts(jwts: string[], test_num: number) {
  const get_user_information_promises = [];
  for (const jwt of jwts) {
    // Send upate request
    get_user_information_promises.push(
      test_fetch(
        ACCOUNT_AUTH_URL(test_num),
        {
          headers: {
            "Authorization": `Bearer ${jwt}`,
          },
          method: "GET",
        },
        undefined,
        false,
      ),
    );
  }
  const responses = await Promise.all(get_user_information_promises);
  const body_promises = [];
  for (const response of responses) {
    body_promises.push(response.json() as Promise<AccountGetModel>);
  }
  return await Promise.all(body_promises);
}
