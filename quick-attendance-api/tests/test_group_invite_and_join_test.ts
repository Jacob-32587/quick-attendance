import { assert } from "@std/assert";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import { GroupInvitePutReq } from "../models/group/group_invite_put_req.ts";
import { GroupListGetRes } from "../models/group/group_list_res.ts";
import { cleanup_test_step, init_test_step, test_fetch, test_fetch_json } from "../util/testing.ts";
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
      const [rocco_jwt, maeve_jwt, henrik_jwt, indie_jwt] = await create_and_login_test_users(
        test_num,
      );

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
      test_fetch_json(GROUP_AUTH_URL(test_num), "POST", owner_jwt, {
        "group_name": "Rocco's group of friends",
        "group_description": "I wanna track when I'm with friends.",
      } as GroupPostReq);

      const owner_group_list_res = await test_fetch_json(
        GROUP_AUTH_URL(test_num) + "/list",
        "GET",
        owner_jwt,
        undefined,
        undefined,
        false,
      );

      const owner_group_list = (await owner_group_list_res.json()) as GroupListGetRes;

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

      let accept_member_entities = await get_user_accounts(
        accept_members,
        test_num,
      );
      let deny_member_entity = (await get_user_accounts(
        [deny_member],
        test_num,
      ))[0];

      // Ensure that all users have an invite
      assert(
        accept_member_entities.every((x) => (x.fk_pending_group_ids?.length ?? 0) === 1) &&
          deny_member_entity.fk_pending_group_ids?.length === 1,
      );

      for (const entity of accept_member_entities) {
        await test_fetch(ACCOUNT_AUTH_URL(test_num) + "/invite", {
          headers: {
            "Authorization": `Bearer ${entity.jwt}`,
            "content-type": "application/json",
          },
          method: "PUT",
          body: JSON.stringify({
            account_invite_jwt: (entity.fk_pending_group_ids ?? [])[0],
            accept: true,
          } as AccountInviteActionPutReq),
        });
      }

      await test_fetch(ACCOUNT_AUTH_URL(test_num) + "/invite", {
        headers: {
          "Authorization": `Bearer ${deny_member_entity.jwt}`,
          "content-type": "application/json",
        },
        method: "PUT",
        body: JSON.stringify({
          account_invite_jwt: (deny_member_entity.fk_pending_group_ids ?? [])[0],
          accept: false,
        } as AccountInviteActionPutReq),
      });

      // Ensure that all users invites are gone
      accept_member_entities = await get_user_accounts(
        accept_members,
        test_num,
      );
      deny_member_entity = (await get_user_accounts(
        [deny_member],
        test_num,
      ))[0];

      console.log(accept_member_entities);
      console.log(deny_member_entity);

      assert(
        accept_member_entities.every((x) =>
          (x.fk_pending_group_ids?.length ?? 0) === 0 ||
          (x.fk_pending_group_ids?.length ?? null) === null
        ) && (
          (deny_member_entity.fk_pending_group_ids?.length ?? 0) === 0 ||
          (deny_member_entity.fk_pending_group_ids?.length ?? null) === null
        ),
      );
    });

    //////////////////////////////////////////////
    // Rocoo, Henrik, Maeve check their groups //
    ////////////////////////////////////////////

    await cleanup_test_step(test_num, t, sp);
  },
);
