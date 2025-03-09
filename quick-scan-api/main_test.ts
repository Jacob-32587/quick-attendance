import { assert, assertFalse } from "@std/assert";
import { AccountPostReq } from "./models/account/account_post_req.ts";
import { AccountLoginPostRes } from "./models/account/account_login_post_res.ts";
import { AccountLoginPostReq } from "./models/account/account_login_post_req.ts";
import { sleep } from "./util/sleep.ts";
import { UnknownException } from "effect/Cause";
import AccountGetModel from "./models/account/account_get_model.ts";
import { GroupPostReq } from "./models/group/group_post_req.ts";
import { GroupInvitePutReq } from "./models/group/group_invite_put_req.ts";
import { GroupListGetRes } from "./models/group/group_list_res.ts";
import {
  assertNever,
  cleanup_test_step,
  init_test_step,
  test_fetch,
} from "./util/testing.ts";

const URL = (n: number) => `http://0.0.0.0:${8080 + n}/quick-scan-api`;
const ACCOUNT_URL = (n: number) => `${URL(n)}/account`;
const ACCOUNT_AUTH_URL = (n: number) => `${URL(n)}/auth/account`;
const GROUP_URL = (n: number) => `${URL(n)}/group`;
const GROUP_AUTH_URL = (n: number) => `${URL(n)}/auth/group`;

const user_rocco_mason = {
  "username": "Rocco Mason",
  "email": "rocco243@bar.com",
  "first_name": "Rocco",
  "last_name": "Mason",
  "password": "rocco_is_cool",
} as AccountPostReq;

const user_maeve_berg = {
  "username": "Maeve Berg",
  "email": "maeve_b@bar.com",
  "first_name": "Maeve",
  "last_name": "B",
  "password": "lovely_puppy_992",
} as AccountPostReq;

const user_henrik_wright = {
  "username": "Henrik Wright",
  "email": "henrik@baz.org",
  "first_name": "Henrik",
  "password": "long-passwords-are-cool-482-260-8822",
} as AccountPostReq;

const user_indie_conway = {
  "username": "Indie Conway",
  "email": "indieC@fun.com",
  "first_name": "Indie",
  "last_name": "Conway",
  "password": "conway_indie_2001",
} as AccountPostReq;

const user_array = [
  user_rocco_mason,
  user_maeve_berg,
  user_henrik_wright,
  user_indie_conway,
];

async function create_and_login_test_users(test_num: number) {
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

// Ensure test information can be retrieved as is correct
Deno.test(
  async function get_user_information(t: Deno.TestContext) {
    const test_num = 1;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      // Create a login users
      const logged_in_users_jwts = await create_and_login_test_users(test_num);

      const get_user_information_promises: Promise<Response>[] = [];

      // Get account information for each user
      for (const jwt of logged_in_users_jwts) {
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

      const user_data_responses = await Promise.all(
        get_user_information_promises,
      );

      const zipped_data = user_data_responses.map((x, y) => ({
        get_data_res: x,
        user_data: user_array[y],
      }));

      // Ensure account information is correct
      for (const { get_data_res, user_data } of zipped_data) {
        const account = (await get_data_res.json()) as AccountGetModel;
        assert(account?.email == user_data?.email);
        assert(account?.username == user_data?.username);
        assert(account?.first_name == user_data?.first_name);
        assert(account?.last_name == user_data?.last_name);
      }
    });

    await cleanup_test_step(test_num, t, sp);
  },
);

Deno.test(
  async function invite_to_group_and_accept(t: Deno.TestContext) {
    const test_num = 2;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      // Create a login users
      const [rocco_jwt, maeve_jwt, henrik_jwt, indie_jwt] =
        await create_and_login_test_users(test_num);

      const owner = rocco_jwt;
      const invite_members = [maeve_jwt, henrik_jwt, indie_jwt].map((x, y) => ({
        jwt: x,
        user_data: user_array[y + 1],
      }));
      const accept_members = [maeve_jwt, henrik_jwt];
      const deny_member = indie_jwt;

      /////////////////////////////////////////////////////////////////
      // Rocco creates a group and invites Maeve, Henrik, and Indie //
      ///////////////////////////////////////////////////////////////
      await test_fetch(GROUP_AUTH_URL(test_num), {
        headers: {
          "Authorization": `Bearer ${rocco_jwt}`,
          "content-type": "application/json",
        },
        method: "POST",
        body: JSON.stringify({
          "group_name": "Rocco's group of friends",
          "group_description":
            "Rocco's close group of friends, I want to track when I'm with my friends.",
        } as GroupPostReq),
      });

      const rocco_group_list_res = await test_fetch(
        GROUP_AUTH_URL(test_num),
        {
          headers: {
            "Authorization": `Bearer ${rocco_jwt}`,
          },
          method: "GET",
        },
        undefined,
        false,
      );

      const rocco_group_list =
        (await rocco_group_list_res.json()) as GroupListGetRes;

      assert(rocco_group_list.owned_groups.length === 1);
      assert(
        rocco_group_list.owned_groups[0].owner_username ===
          user_rocco_mason.username,
      );
      assert(rocco_group_list.managed_groups.length === 0);
      assert(rocco_group_list.memeber_groups.length === 0);

      await test_fetch(GROUP_AUTH_URL(test_num) + "/invite", {
        headers: {
          "Authorization": `Bearer ${rocco_jwt}`,
          "content-type": "application/json",
        },
        method: "PUT",
        body: JSON.stringify({
          "usernames": invite_members.map((x) => x.user_data.username),
          "group_id": rocco_group_list.owned_groups[0].group_id,
        } as GroupInvitePutReq),
      });
    });
    await cleanup_test_step(test_num, t, sp);
  },
);
