import { assert } from "@std/assert";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import { GroupInvitePutReq } from "../models/group/group_invite_put_req.ts";
import { GroupListGetRes } from "../models/group/group_list_res.ts";
import {
  cleanup_test_step,
  init_test_step,
  test_fetch,
} from "../util/testing.ts";
import {
  ACCOUNT_AUTH_URL,
  create_and_login_test_users,
  get_user_accounts,
  GROUP_AUTH_URL,
  URL,
  user_array,
  user_rocco_mason,
} from "./main_test.ts";
import { AccountInviteActionPutReq } from "../models/account/account_invite_accept_put_req.ts";

// Ensure users can be invited to groups and accept invites
Deno.test(
  async function invite_to_group_and_accept(t: Deno.TestContext) {
    const test_num = 2;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      // Create a login users
      const [rocco_jwt, maeve_jwt, henrik_jwt, indie_jwt] =
        await create_and_login_test_users(test_num);

      const owner_jwt = rocco_jwt;
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
          "Authorization": `Bearer ${owner_jwt}`,
          "content-type": "application/json",
        },
        method: "POST",
        body: JSON.stringify({
          "group_name": "Rocco's group of friends",
          "group_description":
            "Rocco's close group of friends, I want to track when I'm with my friends.",
        } as GroupPostReq),
      });

      const owner_group_list_res = await test_fetch(
        GROUP_AUTH_URL(test_num) + "/list",
        {
          headers: {
            "Authorization": `Bearer ${owner_jwt}`,
          },
          method: "GET",
        },
        undefined,
        false,
      );

      const owner_group_list =
        (await owner_group_list_res.json()) as GroupListGetRes;

      assert(owner_group_list.owned_groups.length === 1);
      assert(
        owner_group_list.owned_groups[0].owner_username ===
          user_rocco_mason.username,
      );
      assert(owner_group_list.managed_groups.length === 0);
      assert(owner_group_list.memeber_groups.length === 0);

      await test_fetch(GROUP_AUTH_URL(test_num) + "/invite", {
        headers: {
          "Authorization": `Bearer ${owner_jwt}`,
          "content-type": "application/json",
        },
        method: "PUT",
        body: JSON.stringify({
          "usernames": invite_members.map((x) => x.user_data.username),
          "group_id": owner_group_list.owned_groups[0].group_id,
          "is_manager_invite": false,
        } as GroupInvitePutReq),
      });

      ////////////////////////////////////////////
      // Henrik and Maeve accept, Indiea denys //
      //////////////////////////////////////////

      let member_entities = await get_user_accounts(
        accept_members,
        test_num,
      );

      // Ensure that all users have an invite
      assert(
        member_entities.every((x) =>
          (x.fk_pending_group_ids?.length ?? 0) === 1
        ),
      );

      for (const accept_member of accept_members) {
        await test_fetch(ACCOUNT_AUTH_URL(test_num) + "/invite", {
          headers: {
            "Authorization": `Bearer ${owner_jwt}`,
            "content-type": "application/json",
          },
          method: "PUT",
          body: JSON.stringify({
            account_invite_jwt: accept_member,
            accept: true,
          } as AccountInviteActionPutReq),
        });
      }

      await test_fetch(ACCOUNT_AUTH_URL(test_num) + "/invite", {
        headers: {
          "Authorization": `Bearer ${owner_jwt}`,
          "content-type": "application/json",
        },
        method: "PUT",
        body: JSON.stringify({
          account_invite_jwt: deny_member,
          accept: true,
        } as AccountInviteActionPutReq),
      });

      // Ensure that all users invites are gone
      member_entities = await get_user_accounts(
        accept_members,
        test_num,
      );

      assert(
        member_entities.every((x) =>
          (x.fk_pending_group_ids?.length ?? 0) === 1
        ),
      );
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
