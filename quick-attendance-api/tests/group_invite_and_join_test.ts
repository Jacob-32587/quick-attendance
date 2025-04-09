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
  URL,
} from "./main_test.ts";

//#region additonal users
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

const user_jane_doe = {
  username: "jane.doe789",
  email: "jane.doe789@examplemail.com",
  first_name: "Jane",
  last_name: "Doe",
  password: "password123!",
};

const user_john_smith = {
  username: "john_smith_2024",
  email: "john.smith2024@domainmail.com",
  first_name: "John",
  last_name: "Smith",
  password: "securePass2025",
};

const user_mary_jones = {
  username: "mary_jones_abc",
  email: "mary_jones1234@mailservice.com",
  first_name: "Mary",
  last_name: "Jones",
  password: "mypassword567",
};

const user_robert_johnson = {
  username: "r.johnson_101",
  email: "robert.johnson_101@webmail.com",
  first_name: "Robert",
  last_name: "Johnson",
  password: "robert1234!",
};

const user_alice_williams = {
  username: "alice_williams_2020",
  email: "alice_w2020@outlook.com",
  first_name: "Alice",
  last_name: "Williams",
  password: "alicepass987",
};

const user_emily_clark = {
  username: "emily_clark93",
  email: "emily.clark93@randommail.org",
  first_name: "Emily",
  last_name: "Clark",
  password: "emilySecure@2023",
};

const user_michael_brown = {
  username: "michael_brown_22",
  email: "michael.brown22@mailbox.com",
  first_name: "Michael",
  last_name: "Brown",
  password: "michael2025pass",
};

const user_lisa_martinez = {
  username: "lisa_martinez_88",
  email: "lisa.martinez88@mydomain.net",
  first_name: "Lisa",
  last_name: "Martinez",
  password: "lisaSecret@88",
};

const user_nick_taylor = {
  username: "nick_taylor_555",
  email: "nick_taylor555@protonmail.com",
  first_name: "Nick",
  last_name: "Taylor",
  password: "nickpassword555",
};

const user_katherine_lee = {
  username: "katherine_lee_777",
  email: "katherine.lee777@fastmail.com",
  first_name: "Katherine",
  last_name: "Lee",
  password: "kathlee1234",
};

const user_oliver_garcia = {
  username: "oliver.garcia_101",
  email: "oliver_garcia101@yahoo.com",
  first_name: "Oliver",
  last_name: "Garcia",
  password: "oliverGarcia@101",
};

export const user_array = [
  user_luca_richard,
  user_mabel_terrel,
  user_rayden_garrett,
  user_nola_lozano,
  user_kylie_mccoy,
  user_selene_fernadez,
  user_grayson_patterson,
  user_jane_doe,
  user_john_smith,
  user_mary_jones,
  user_robert_johnson,
  user_alice_williams,
  user_emily_clark,
  user_michael_brown,
  user_lisa_martinez,
  user_nick_taylor,
  user_katherine_lee,
  user_oliver_garcia,
];
//#endregion
// Ensure users can be invited to groups and accept invites
Deno.test(
  "Creates a group",
  async function invite_to_group_and_accept(t: Deno.TestContext) {
    const test_num = 2;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      const create_group_ret = await create_users_and_group(test_num);
      const additonal_users = await create_and_login_test_users(test_num, user_array);
      let additonal_user_accounts = await get_users_accounts(additonal_users, test_num);

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

      await test_fetch_json(GROUP_AUTH_URL(test_num) + "/invite", "PUT", rocco.group.jwt, {
        "usernames": additonal_user_accounts.map((x) => x.username),
        "group_id": rocco.group.group_id,
        "is_manager_invite": false,
      } as GroupInvitePutReq);

      additonal_user_accounts = await get_users_accounts(additonal_users, test_num);

      for (const user of additonal_user_accounts) {
        await test_fetch_json(ACCOUNT_AUTH_URL(test_num) + "/invite", "PUT", user.jwt, {
          account_invite_jwt: (user.fk_pending_group_ids ?? [])[0],
          accept: true,
        } as AccountInviteActionPutReq);
      }
      //#endregion
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
