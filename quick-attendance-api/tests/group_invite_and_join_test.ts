import { AccountInviteActionPutReq } from "../models/account/account_invite_accept_put_req.ts";
import { AccountPostReq } from "../models/account/account_post_req.ts";
import { GroupInvitePutReq } from "../models/group/group_invite_put_req.ts";
import HttpStatusCode from "../util/http_status_code.ts";
import { cleanup_test_step, init_test_step, test_fetch_json } from "../util/testing.ts";
import {
  ACCOUNT_AUTH_URL,
  create_and_login_test_users,
  create_users_and_group,
  get_users_accounts,
  get_users_groups_and_accounts,
  GROUP_AUTH_URL,
  invite_additonal_users,
  URL,
} from "./main_test.ts";

// Ensure users can be invited to groups and accept invites
Deno.test(
  "Creates a group",
  async function invite_to_group_and_accept(t: Deno.TestContext) {
    const test_num = 2;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      const create_group_ret = await create_users_and_group(test_num);

      const [rocco, maeve, henrik, indie] = await get_users_groups_and_accounts(
        create_group_ret.user_jwts,
        create_group_ret.group_id,
        test_num,
      );

      //#region Attempt to re-invite henrik to the group, this should return a CONFLICT error status code
      await test_fetch_json(
        GROUP_AUTH_URL(test_num) + "/invite",
        "PUT",
        rocco.account.jwt,
        {
          "usernames": [henrik.account.username],
          "group_id": create_group_ret.group_id,
          "is_manager_invite": false,
        } as GroupInvitePutReq,
        (res) => {
          if (res.status === HttpStatusCode.CONFLICT) {
            return Promise.resolve(true);
          }
          return Promise.resolve(false);
        },
        true,
        false,
      );
      //#endregion
      //#region Invite more membes to Rocco's group and they accept
      await invite_additonal_users(test_num, rocco.account.jwt, rocco.group.group_id);
      //#endregion
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
