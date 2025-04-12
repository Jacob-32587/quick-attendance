import { AccountPostReq } from "../models/account/account_post_req.ts";
import { AccountLoginPostRes } from "../models/account/account_login_post_res.ts";
import { AccountLoginPostReq } from "../models/account/account_login_post_req.ts";
import { assertNever, test_fetch, test_fetch_json } from "../util/testing.ts";
import AccountGetModel from "../models/account/account_get_model.ts";
import { assert } from "@std/assert/assert";
import { GroupListGetRes } from "../models/group/group_list_res.ts";
import { GroupPostReq } from "../models/group/group_post_req.ts";
import { GroupInvitePutReq } from "../models/group/group_invite_put_req.ts";
import { AccountInviteActionPutReq } from "../models/account/account_invite_accept_put_req.ts";
import { GroupGetRes } from "../models/group/group_get_res.ts";
import { Uuid } from "../util/uuid.ts";

export const DOMAIN_AND_PORT = (n: number) => `127.0.0.1:${8080 + n}`;
export const URL = (n: number) => `http://${DOMAIN_AND_PORT(n)}/quick-attendance-api`;
export const ACCOUNT_URL = (n: number) => `${URL(n)}/account`;
export const ACCOUNT_AUTH_URL = (n: number) => `${URL(n)}/auth/account`;
export const GROUP_URL = (n: number) => `${URL(n)}/group`;
export const GROUP_AUTH_URL = (n: number) => `${URL(n)}/auth/group`;
export const ATTENDANCE_URL = (n: number) => `${URL(n)}/attendance`;
export const ATTENDANCE_AUTH_URL = (n: number) => `${URL(n)}/auth/attendance`;

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

//#region additonal users
export const user_luca_richard = {
  username: "luca_richard93",
  email: "luca.richard93@domain.com",
  first_name: "Luca",
  last_name: "Richard",
  password: "Luca#2023Rich@rd!",
};
export const user_mabel_terrel = {
  username: "mabel_terrell88",
  email: "mabel_terrell88@randommail.net",
  first_name: "Mabel",
  last_name: "Terrell",
  password: "M@belT3rrell$88!",
};
export const user_rayden_garrett = {
  username: "rayden.garrett7",
  email: "rayden.garrett7@service.org",
  first_name: "Rayden",
  last_name: "Garrett",
  password: "R@ydEn_7G@rrett2024!",
};
export const user_nola_lozano = {
  username: "nola.lozano_19",
  email: "nola.lozano_19@mailbox.com",
  first_name: "Nola",
  last_name: "Lozano",
  password: "Nola19#Loz@no2024!",
};
export const user_kylie_mccoy = {
  username: "kylie.mccoy_22",
  email: "kylie.mccoy_22@outlook.co.uk",
  first_name: "Kylie",
  last_name: "McCoy",
  password: "Kylie!22M@cC0y$",
};
export const user_selene_fernadez = {
  username: "selene_fernandez93",
  email: "selene_fernandez93@provider.biz",
  first_name: "Selene",
  last_name: "Fernandez",
  password: "S3l3n3@F3rn@nd3z93!",
};
export const user_grayson_patterson = {
  username: "grayson.patterson99",
  email: "grayson.patterson99@domain.io",
  first_name: "Grayson",
  last_name: "Patterson",
  password: "Gr@ys0n#P@tt3r$on99!",
};

export const user_jane_doe = {
  username: "jane.doe789",
  email: "jane.doe789@examplemail.com",
  first_name: "Jane",
  last_name: "Doe",
  password: "password123!",
};

export const user_john_smith = {
  username: "john_smith_2024",
  email: "john.smith2024@domainmail.com",
  first_name: "John",
  last_name: "Smith",
  password: "securePass2025",
};

export const user_mary_jones = {
  username: "mary_jones_abc",
  email: "mary_jones1234@mailservice.com",
  first_name: "Mary",
  last_name: "Jones",
  password: "mypassword567",
};

export const user_robert_johnson = {
  username: "r.johnson_101",
  email: "robert.johnson_101@webmail.com",
  first_name: "Robert",
  last_name: "Johnson",
  password: "robert1234!",
};

export const user_alice_williams = {
  username: "alice_williams_2020",
  email: "alice_w2020@outlook.com",
  first_name: "Alice",
  last_name: "Williams",
  password: "alicepass987",
};

export const user_emily_clark = {
  username: "emily_clark93",
  email: "emily.clark93@randommail.org",
  first_name: "Emily",
  last_name: "Clark",
  password: "emilySecure@2023",
};

export const user_michael_brown = {
  username: "michael_brown_22",
  email: "michael.brown22@mailbox.com",
  first_name: "Michael",
  last_name: "Brown",
  password: "michael2025pass",
};

export const user_lisa_martinez = {
  username: "lisa_martinez_88",
  email: "lisa.martinez88@mydomain.net",
  first_name: "Lisa",
  last_name: "Martinez",
  password: "lisaSecret@88",
};

export const user_nick_taylor = {
  username: "nick_taylor_555",
  email: "nick_taylor555@protonmail.com",
  first_name: "Nick",
  last_name: "Taylor",
  password: "nickpassword555",
};

export const user_katherine_lee = {
  username: "katherine_lee_777",
  email: "katherine.lee777@fastmail.com",
  first_name: "Katherine",
  last_name: "Lee",
  password: "kathlee1234",
};

export const user_oliver_garcia = {
  username: "oliver.garcia_101",
  email: "oliver_garcia101@yahoo.com",
  first_name: "Oliver",
  last_name: "Garcia",
  password: "oliverGarcia@101",
};

export const additonal_user_array = [
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

export async function create_and_login_test_users(
  test_num: number,
  user_array_override?: AccountPostReq[],
) {
  const create_user_promises: Promise<Response>[] = [];
  const users_to_create = user_array_override ?? user_array;
  // Create test user accounts
  for (const user of users_to_create) {
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
  for (const user of users_to_create) {
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

  // Ensure JWT's are returned in the order users were specified
  const ordered_jwts = [];

  for (let i = 0; i < users_to_create.length; i++) {
    ordered_jwts.push(user_jwts.get(users_to_create[i].email) ?? assertNever());
  }

  return ordered_jwts;
}

export async function get_users_accounts(jwts: string[], test_num: number) {
  const get_user_information_promises = [];
  for (const jwt of jwts) {
    // Send upate request
    get_user_information_promises.push(
      test_fetch_json(ACCOUNT_AUTH_URL(test_num), "GET", jwt, null, null, false),
    );
  }
  const responses = await Promise.all(get_user_information_promises);
  const body_promises = [];
  for (const response of responses) {
    body_promises.push(
      response.json() as Promise<AccountGetModel & { jwt: string }>,
    );
  }

  const get_rets = await Promise.all(body_promises);
  for (let i = 0; i < get_rets.length; i++) {
    get_rets[i].jwt = jwts[i];
  }
  return get_rets;
}

export async function get_users_groups(jwts: string[], group_id: Uuid, test_num: number) {
  const get_user_group_promises = [];
  for (const jwt of jwts) {
    // Send upate request
    get_user_group_promises.push(
      test_fetch_json(
        `${GROUP_AUTH_URL(test_num)}?group_id=${group_id}`,
        "GET",
        jwt,
        null,
        null,
        false,
      ),
    );
  }
  const responses = await Promise.all(get_user_group_promises);
  const body_promises = [];
  for (const response of responses) {
    body_promises.push(
      response.json() as Promise<GroupGetRes & { jwt: string }>,
    );
  }

  const get_rets = await Promise.all(body_promises);
  for (let i = 0; i < get_rets.length; i++) {
    get_rets[i].jwt = jwts[i];
  }
  return get_rets;
}

export async function get_users_groups_and_accounts(
  jwts: string[],
  group_id: Uuid,
  test_num: number,
) {
  const account_get_p = get_users_accounts(jwts, test_num);
  const user_groups = await get_users_groups(jwts, group_id, test_num);
  const user_accounts = await account_get_p;
  return user_groups.map((u, i) => ({ group: u, account: user_accounts[i] }));
}

/**
 * @description Create a group owned by Rocco with two members. Maeve
 * and Henrik accept the first invite, Indie denies. Then Indie is invited
 * again, as a manager, and accepts.
 */
export async function create_users_and_group(test_num: number) {
  // Create and login users
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

  //#region Rocco creates a group and invites Maeve, Henrik, and Indie
  await test_fetch_json(GROUP_AUTH_URL(test_num), "POST", owner_jwt, {
    "group_name": "Rocco's group of friends",
    "group_description":
      "Rocco's close group of friends, I want to track when I'm with my friends.",
  } as GroupPostReq);

  const owner_group_list_res = await test_fetch_json(
    GROUP_AUTH_URL(test_num) + "/list",
    "GET",
    owner_jwt,
    null,
    null,
  );

  const owner_group_list = (await owner_group_list_res.json()) as GroupListGetRes;

  assert(owner_group_list.owned_groups.length === 1);
  assert(
    owner_group_list.owned_groups[0].owner_username ===
      user_rocco_mason.username,
  );
  assert(owner_group_list.managed_groups.length === 0);
  assert(owner_group_list.member_groups.length === 0);

  await test_fetch_json(GROUP_AUTH_URL(test_num) + "/invite", "PUT", owner_jwt, {
    "usernames": invite_members.map((x) => x.user_data.username),
    "group_id": owner_group_list.owned_groups[0].group_id,
    "is_manager_invite": false,
  } as GroupInvitePutReq);

  //#endregion

  //#region Henrik and Maeve accept, Indie denies

  let accept_member_entities = await get_users_accounts(
    accept_members,
    test_num,
  );
  let deny_member_entity = (await get_users_accounts(
    [deny_member],
    test_num,
  ))[0];
  // Ensure that all users have an invite
  assert(
    accept_member_entities.every((x) => (x.fk_pending_group_ids?.length ?? 0) === 1) &&
      deny_member_entity.fk_pending_group_ids?.length === 1,
  );

  for (const entity of accept_member_entities) {
    await test_fetch_json(ACCOUNT_AUTH_URL(test_num) + "/invite", "PUT", entity.jwt, {
      account_invite_jwt: (entity.fk_pending_group_ids ?? [])[0],
      accept: true,
    } as AccountInviteActionPutReq);
  }

  await test_fetch_json(ACCOUNT_AUTH_URL(test_num) + "/invite", "PUT", deny_member_entity.jwt, {
    account_invite_jwt: (deny_member_entity.fk_pending_group_ids ?? [])[0],
    accept: false,
  } as AccountInviteActionPutReq);

  // Ensure that all users invites are gone
  accept_member_entities = await get_users_accounts(
    accept_members,
    test_num,
  );
  deny_member_entity = (await get_users_accounts(
    [deny_member],
    test_num,
  ))[0];

  // Ensure that all users have no more pending invites
  assert(
    accept_member_entities.every((x) =>
      (x.fk_pending_group_ids?.length ?? 0) === 0 ||
      (x.fk_pending_group_ids?.length ?? null) === null
    ) && (
      (deny_member_entity.fk_pending_group_ids?.length ?? 0) === 0 ||
      (deny_member_entity.fk_pending_group_ids?.length ?? null) === null
    ),
  );

  //#endregion

  //#region Rocoo, Henrik, Maeve check their groups
  for (const entity of accept_member_entities) {
    await test_fetch_json(
      GROUP_AUTH_URL(test_num) +
        `?group_id=${owner_group_list.owned_groups[0].group_id}`,
      "GET",
      entity.jwt,
      null,
      async (res) => {
        const group = (await res.json()) as GroupGetRes;
        const pass = group.event_count === 0 &&
            group.group_name === "Rocco's group of friends" &&
            group.members?.length === 2 && group.members.every((x) => x.unique_id === null) &&
            group.pending_members === null || group.pending_members?.length === 0;

        if (!pass) {
          console.log("GROUP MEMBER DID NOT PASS: ", group);
        }
        return pass;
      },
    );
  }

  await test_fetch_json(
    GROUP_AUTH_URL(test_num) +
      `?group_id=${owner_group_list.owned_groups[0].group_id}`,
    "GET",
    owner_jwt,
    null,
    async (res) => {
      const group = (await res.json()) as GroupGetRes;

      const pass = group.event_count === 0 && group.group_name === "Rocco's group of friends" &&
        group.members?.length === 2 && group.members.every((x) => x.unique_id === null);
      if (!pass) {
        console.log("GROUP OWNER DID NOT PASS: ", group);
      }
      return pass;
    },
  );
  //#endregion

  //#region Rocco invites Indie as a manager and Indie accepts
  await test_fetch_json(GROUP_AUTH_URL(test_num) + "/invite", "PUT", owner_jwt, {
    "usernames": [invite_members[2].user_data.username],
    "group_id": owner_group_list.owned_groups[0].group_id,
    "is_manager_invite": true,
  } as GroupInvitePutReq);

  const accept_manager_entity = (await get_users_accounts(
    [deny_member],
    test_num,
  ))[0];

  await test_fetch_json(ACCOUNT_AUTH_URL(test_num) + "/invite", "PUT", accept_manager_entity.jwt, {
    account_invite_jwt: (accept_manager_entity.fk_pending_group_ids ?? [])[0],
    accept: true,
  } as AccountInviteActionPutReq);

  //#endregion

  //#region The state of the group is checked

  await test_fetch_json(
    GROUP_AUTH_URL(test_num) + `?group_id=${owner_group_list.owned_groups[0].group_id}`,
    "GET",
    owner_jwt,
    null,
    async (res) => {
      const group = (await res.json()) as GroupGetRes;

      const pass = group.event_count === 0 &&
          group.group_name === "Rocco's group of friends" &&
          group.members?.length === 2 && group.members.every((x) => x.unique_id === null) &&
          group.managers?.length === 1 &&
          group.pending_members === null || group.pending_members?.length === 0;

      if (!pass) {
        console.log("GROUP MEMBER DID NOT PASS: ", group);
      }
      return pass;
    },
  );
  //#endregion
  return {
    user_jwts: [rocco_jwt, maeve_jwt, henrik_jwt, indie_jwt],
    group_id: owner_group_list.owned_groups[0].group_id,
  };
}

export async function invite_additonal_users(test_num: number, owner_jwt: string, group_id: Uuid) {
  const additonal_users = await create_and_login_test_users(test_num, additonal_user_array);
  let additonal_user_accounts = await get_users_accounts(additonal_users, test_num);
  await test_fetch_json(GROUP_AUTH_URL(test_num) + "/invite", "PUT", owner_jwt, {
    "usernames": additonal_user_accounts.map((x) => x.username),
    "group_id": group_id,
    "is_manager_invite": false,
  } as GroupInvitePutReq);

  additonal_user_accounts = await get_users_accounts(additonal_users, test_num);

  for (const user of additonal_user_accounts) {
    await test_fetch_json(ACCOUNT_AUTH_URL(test_num) + "/invite", "PUT", user.jwt, {
      account_invite_jwt: (user.fk_pending_group_ids ?? [])[0],
      accept: true,
    } as AccountInviteActionPutReq);
  }
  return additonal_user_accounts;
}
