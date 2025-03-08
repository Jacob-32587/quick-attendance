import { assert, assertEquals, assertFalse } from "@std/assert";
import { AccountPostReq } from "./models/account/account_post_req.ts";
import { AccountLoginPostRes } from "./models/account/account_login_post_res.ts";
import { AccountLoginPostReq } from "./models/account/account_login_post_req.ts";
import { exists } from "jsr:@std/fs/exists";
import { server } from "./main.ts";
import { sleep } from "./util/sleep.ts";

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

/**
 * @description This will spawn and instance of a self contained server with it's own database.
 * If the server fails to start this function will throw. You must ensure that test numbers are
 * unique between individuals tests.
 * @param test_num - The unique test number
 * @returns Handle to the child process (self contained server instance)
 */
async function init_test(test_num: number) {
  // Create directory for deno-kv SQL lite files and spawn a server instance
  Deno.mkdir(`./test-${test_num}`);
  const cmd = new Deno.Command(Deno.execPath(), {
    args: [
      "run",
      "--allow-net",
      "--unstable-kv",
      "--allow-read",
      "--allow-write",
      "main.ts",
      "--test-number",
      test_num.toString(),
    ],
  });

  const c_p = cmd.spawn();

  // Wait for the server to start
  await sleep(2000);

  // Attempt to get a response from the server, if the server takes more than 5 seconds
  // to respond something is wrong.
  const res = await fetch(URL(test_num), { signal: AbortSignal.timeout(5000) });

  const ok_health_check = res.ok;

  if (!ok_health_check) {
    console.log(`Failed to launch server process for test ${test_num}`);
    assertFalse(true);
  }
  res.body?.cancel();
  console.log(`Failed to launch server process for test ${test_num}`);
  return c_p;
}

/**
 * @description Cleanup that must be called before the program finishes execution. This
 * ensures all ephemeral data is deleted and the server instance is killed.
 * @param test_num - The test number to be cleaned up
 * @param server_process - Handle to the child process (self contained server instance)
 */
async function cleanup_test(
  test_num: number,
  server_process: Deno.ChildProcess | null,
) {
  Deno.remove(`./test-${test_num}`, { recursive: true });

  // If there is a server process kill it and wait for it to end
  if (server_process != null) {
    server_process.kill();
    await sleep(2000);
  }
}

/**
 * @description Thin wrapper around the {@link fetch} function, if you would like to
 * know more about other parameters check there. This function encapsulates receptive
 * steps done after each fetch call, such as ensuring an OK response.
 * @param maybe_check_fn - Optional check function that allows for additional logic to be checked by {@link assert}.
 * @param consume_body - Specify if the body should be consumed by the function on successful requests. Note that on
 * failing requests the body will always be consumed. This will default not true if a check function is not specified,
 * if one is then false. It is assumed that that check function will need to read the body, if
 * this is not the case this parameter can be set to true manually.
 */
async function test_fetch(
  input: RequestInfo | URL,
  init?: RequestInit & { client?: Deno.HttpClient },
  maybe_check_fn?: (
    res: Response,
    req?: RequestInit & { client?: Deno.HttpClient },
  ) => Promise<boolean>,
  consume_body?: boolean,
): Promise<Response> {
  if (consume_body === undefined && maybe_check_fn === undefined) {
    consume_body = true;
  } else {
    consume_body = false;
  }
  const ret = await fetch(input, init);
  const check_fn = await (maybe_check_fn ?? (() => true))(ret, init);

  if (!ret.ok || !check_fn) {
    console.log("Request", init);
    console.log(ret);
    try {
      console.log(await ret.json());
    } catch {
      console.log(ret.text());
    }
  }

  try {
    assert(ret.ok);
    assert(check_fn);
  } finally {
    // Body is not being handled by the user or internally, cancel
    // any streaming that may be occuring
    if (consume_body && ret.ok && check_fn) {
      await ret.body?.cancel();
    }
  }

  return ret;
}

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
    user_jwts.get(user_rocco_mason.email) ?? assertFalse(true),
    user_jwts.get(user_maeve_berg.email) ?? assertFalse(true),
    user_jwts.get(user_henrik_wright.email) ?? assertFalse(true),
    user_jwts.get(user_indie_conway.email) ?? assertFalse(true),
  ];
}

const init_test_step = async (test_num: number, t: Deno.TestContext) => {
  let sp: Deno.ChildProcess | null = null;
  await t.step("init", async () => {
    sp = await init_test(test_num);
  });
  // It seems that typescript gets really confused here as of deno 2.2.3
  // sp is typed as only `null`. This is obvisouly not the case
  return (sp as Deno.ChildProcess | null);
};

const cleanup_test_step = async (
  test_num: number,
  t: Deno.TestContext,
  server_process: Deno.ChildProcess | null,
) => {
  await t.step("cleanup", async () => {
    await cleanup_test(test_num, server_process);
  });
};

Deno.test(
  async function get_user_information(t: Deno.TestContext) {
    const test_num = 1;
    const sp = await init_test_step(test_num, t);

    await t.step("test", async (_) => {
      const logged_in_users_jwts = await create_and_login_test_users(test_num);
      for (const user of logged_in_users_jwts) {
      }
    });

    await cleanup_test_step(test_num, t, sp);
  },
);

// Deno.test(
//   async function invite_users_to_groups(t: Deno.TestContext) {
//     let sp: Deno.ChildProcess | null = null;
//     const test_num = 2;
//     await t.step("init", async () => {
//       sp = await init_test(test_num);
//     });
//
//     await t.step("test", async (_) => {
//       const [owner_jwt, maeve_jwt, henrik_jwt] =
//         await create_and_login_test_users(test_num);
//     });
//
//     await t.step("cleanup", async () => await cleanup_test(test_num, sp));
//   },
// );
