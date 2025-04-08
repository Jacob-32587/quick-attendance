import { AccountPostReq } from "../models/account/account_post_req.ts";
import { GroupInvitePutReq } from "../models/group/group_invite_put_req.ts";
import HttpStatusCode from "../util/http_status_code.ts";
import { cleanup_test_step, init_test_step, test_fetch_json } from "../util/testing.ts";
import {
  create_and_login_test_users,
  create_users_and_group,
  get_users_groups_and_accounts,
  GROUP_AUTH_URL,
  URL,
} from "./main_test.ts";

const user_luca_richard = {
  username: "luca_richard93",
  email: "luca.richard93@domain.com",
  first_name: "Luca",
  last_name: "Richard",
  password: "Luca#2023Rich@rd!",
};
const user_mabel_terrel = {
  username: "mabel_terrell88",
  email: "mabel_terrell88@randommail.net",
  first_name: "Mabel",
  last_name: "Terrell",
  password: "M@belT3rrell$88!",
};
const user_rayden_garrett = {
  username: "rayden.garrett7",
  email: "rayden.garrett7@service.org",
  first_name: "Rayden",
  last_name: "Garrett",
  password: "R@ydEn_7G@rrett2024!",
};
const user_nola_lozano = {
  username: "nola.lozano_19",
  email: "nola.lozano_19@mailbox.com",
  first_name: "Nola",
  last_name: "Lozano",
  password: "Nola19#Loz@no2024!",
};
const user_kylie_mccoy = {
  username: "kylie.mccoy_22",
  email: "kylie.mccoy_22@outlook.co.uk",
  first_name: "Kylie",
  last_name: "McCoy",
  password: "Kylie!22M@cC0y$",
};
const user_selene_fernadez = {
  username: "selene_fernandez93",
  email: "selene_fernandez93@provider.biz",
  first_name: "Selene",
  last_name: "Fernandez",
  password: "S3l3n3@F3rn@nd3z93!",
};
const user_grayson_patterson = {
  username: "grayson.patterson99",
  email: "grayson.patterson99@domain.io",
  first_name: "Grayson",
  last_name: "Patterson",
  password: "Gr@ys0n#P@tt3r$on99!",
};

export const user_array = [
  user_luca_richard,
  user_mabel_terrel,
  user_rayden_garrett,
  user_nola_lozano,
  user_kylie_mccoy,
  user_selene_fernadez,
  user_grayson_patterson,
];

// Ensure users can be invited to groups and accept invites
Deno.test(
  "Creates a group",
  async function invite_to_group_and_accept(t: Deno.TestContext) {
    const test_num = 2;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      const create_group_ret = await create_users_and_group(test_num);
      const additonal_users = await create_and_login_test_users(test_num, user_array);
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

      //#region Create more users, another group and invite and accept
      // await test_fetch_json(GROUP_AUTH_URL(test_num), "POST", owner_jwt, {
      //   "group_name": "Rocco's group of friends",
      //   "group_description":
      //     "Rocco's close group of friends, I want to track when I'm with my friends.",
      // } as GroupPostReq);
      //#endregion
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
