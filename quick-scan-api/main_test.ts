import { assert, assertEquals } from "@std/assert";
import { AccountPostReq } from "./models/account/account_post_req.ts";
import { AccountLoginPostRes } from "./models/account/account_login_post_res.ts";
import { AccountLoginPostReq } from "./models/account/account_login_post_req.ts";
import { server } from "./main.ts";

const URL = "http://0.0.0.0:8080/quick-scan-api";
const ACCOUNT_URL = ``
const ACCOUNT_AUTH_URL = 

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

function init_test() {
  Deno.mkdir("./test");
  const cmd = new Deno.Command(Deno.execPath(), {
    args: [
      "run",
      "--watch",
      "--allow-net",
      "--unstable-kv",
      "--allow-read",
      "--allow-write",
      "--test",
      "main.ts",
    ],
  });

  return cmd.spawn();
}

function cleanup_test(server_process: Deno.ChildProcess) {
  Deno.remove("./test", { recursive: true });
  server_process.kill();
}

async function create_and_login_test_users() {
  // Create test user accounts
  let latest_res = await fetch(URL, {
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(user_rocco_mason),
  });
  assert(latest_res.ok);

  latest_res = await fetch(URL, {
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(user_maeve_berg),
  });
  assert(latest_res.ok);

  latest_res = await fetch(URL, {
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(user_henrik_wright),
  });
  assert(latest_res.ok);

  latest_res = await fetch(URL, {
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(user_indie_conway),
  });
  assert(latest_res.ok);

  // Login users
  latest_res = await fetch(URL, {
    body: JSON.stringify(
      {
        email: user_rocco_mason.email,
        password: user_rocco_mason.password,
      } as AccountLoginPostReq,
    ),
  });
  assert(latest_res.ok);
  const rocco_jwt = ((await latest_res.json()) as AccountLoginPostRes).jwt;
  assert(rocco_jwt !== null || rocco_jwt !== undefined);

  latest_res = await fetch(URL, {
    body: JSON.stringify(
      {
        email: user_maeve_berg.email,
        password: user_maeve_berg.password,
      } as AccountLoginPostReq,
    ),
  });
  assert(latest_res.ok);
  const maeve_jwt = ((await latest_res.json()) as AccountLoginPostRes).jwt;
  assert(maeve_jwt !== null || maeve_jwt !== undefined);

  latest_res = await fetch(URL, {
    body: JSON.stringify(
      {
        email: user_henrik_wright.email,
        password: user_henrik_wright.password,
      } as AccountLoginPostReq,
    ),
  });
  assert(latest_res.ok);
  const henrik_jwt = ((await latest_res.json()) as AccountLoginPostRes).jwt;
  assert(henrik_jwt !== null || henrik_jwt !== undefined);

  latest_res = await fetch(URL, {
    body: JSON.stringify(
      {
        email: user_indie_conway.email,
        password: user_indie_conway.password,
      } as AccountLoginPostReq,
    ),
  });
  assert(latest_res.ok);
  const indie_jwt = ((await latest_res.json()) as AccountLoginPostRes).jwt;
  assert(indie_jwt !== null || indie_jwt !== undefined);

  return { rocco_jwt, maeve_jwt, henrik_jwt, indie_jwt };
}

Deno.test(async function invite_users_to_groups() {
  const server_process = init_test();

  const { rocco_jwt: owner_jwt, maeve_jwt, henrik_jwt } =
    await create_and_login_test_users();
  cleanup_test(server_process);
});
