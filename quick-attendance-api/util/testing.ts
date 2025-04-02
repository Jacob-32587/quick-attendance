import { assert, assertFalse } from "@std/assert";
import { sleep } from "./sleep.ts";
import { io } from "socket.io-client";

/**
 * @description This will spawn and instance of a self contained server with it's own database.
 * If the server fails to start this function will throw. You must ensure that test numbers are
 * unique between individuals tests.
 * @param test_num - The unique test number
 * @returns Handle to the child process (self contained server instance)
 */
async function init_test(test_num: number, base_url: string) {
  // We just want to remove the directory if it exists. We don't care about errors here
  try {
    await Deno.remove(`./test-${test_num}`, { recursive: true });
  } catch {
    //
  }
  // Create directory for deno-kv SQL lite files and spawn a server instance
  await Deno.mkdir(`./test-${test_num}`);
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

  // Attempt to get a response from the server, if the server takes more than 1 second
  // to respond something is wrong.
  const res = await fetch(base_url, { signal: AbortSignal.timeout(1000) });

  const ok_health_check = res.ok;

  if (!ok_health_check) {
    console.log(`Failed to launch server process for test ${test_num}`);
    assertNever();
  }
  res.body?.cancel();
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
    await sleep(4000);
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
 * @returns Promise that will resolve with headers are sent back
 */
export async function test_fetch(
  input: RequestInfo | URL,
  init?: RequestInit & { client?: Deno.HttpClient },
  maybe_check_fn?:
    | ((
      res: Response,
      req?: RequestInit & { client?: Deno.HttpClient },
    ) => Promise<boolean> | undefined)
    | null,
  consume_body?: boolean | null,
): Promise<Response> {
  if (
    (consume_body === undefined || consume_body === null) &&
    (maybe_check_fn === undefined || consume_body === null)
  ) {
    consume_body = true;
  } else {
    consume_body = false;
  }
  const ret = await fetch(input, init);
  const check_fn = await (maybe_check_fn ?? (() => true))(ret, init);

  if (!ret.ok || !check_fn) {
    console.log("Request", init);
    // This could consume the body, in-case it doesn't attempt to anyway
    console.log(ret);
    try {
      console.log(await ret.text());
      // We don't care if this errors, just need to make sure resources are
      // cleaned up
      // deno-lint-ignore no-empty
    } catch {}
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

/**
 * @description Send a test fetch request and optionally include a JSON body and JWT authorization header
 * @template T - Type of the JSON body
 * @param url - URL to send the HTTP request to
 * @param method - method of the HTTP endpoint
 * @param json_body - JSON body of the request
 * @param jwt - Optional authorization header with JWT
 * @param maybe_check_fn - Optional check function that allows for additional logic to be checked by {@link assert}.
 * @param consume_body - Specify if the body should be consumed by the function on successful requests. Note that on
 * failing requests the body will always be consumed. This will default not true if a check function is not specified,
 * if one is then false. It is assumed that that check function will need to read the body, if
 * this is not the case this parameter can be set to true manually.
 * @returns Promise that will resolve with headers are sent back
 */
export async function test_fetch_json<T>(
  url: string,
  method: "PUT" | "GET" | "PATCH" | "DELETE" | "POST",
  jwt?: string | null,
  json_body?: T | null,
  maybe_check_fn?:
    | ((
      res: Response,
      req?: RequestInit & { client?: Deno.HttpClient },
    ) => Promise<boolean> | undefined)
    | null,
  consume_body?: boolean | null,
): Promise<Response> {
  const headers = {} as { [key: string]: string };

  const req_init = {
    headers: headers,
    method: method,
  } as RequestInit;

  // Attach JWT if provided
  if (jwt !== undefined && jwt !== null) {
    headers["Authorization"] = `Bearer ${jwt}`;
  }
  if (json_body !== undefined && json_body !== null) {
    headers["content-type"] = "application/json";
    req_init.body = JSON.stringify(json_body);
  }

  return await test_fetch(
    url,
    req_init,
    maybe_check_fn,
    consume_body,
  );
}

export const init_test_step = async (
  test_num: number,
  t: Deno.TestContext,
  base_url: string,
) => {
  let sp: Deno.ChildProcess | null = null;
  await t.step("init", async () => {
    sp = await init_test(test_num, base_url);
  });
  // It seems that typescript gets really confused here as of deno 2.2.3
  // sp is typed as only `null`. This is obvisouly not the case
  return (sp as Deno.ChildProcess | null);
};

export const cleanup_test_step = async (
  test_num: number,
  t: Deno.TestContext,
  server_process: Deno.ChildProcess | null,
) => {
  await t.step("cleanup", async () => {
    await cleanup_test(test_num, server_process);
  });
};

export function assertNever(): never {
  throw 1;
}

/**
 * @description Opens a websocket connection with the server and verifies
 * that an connection is established. If no connection is made within the
 * first 3 seconds this function will throw an assertion error.
 * @returns Websocket connection
 */
export async function open_ws(domain_and_port: string, jwt: string) {
  const socket = io(`ws://${domain_and_port}`, {
    auth(cb) {
      cb({
        token: jwt,
      });
    },
  });

  // Check if connected for 3 seconds, if no connection was established
  // then fail.
  let socket_check_cnt = 0;
  while (socket.connected === false) {
    if (socket_check_cnt === 30) {
      assert(false, "Unable to establish websocket connection");
    }
    await sleep(100);
    socket_check_cnt++;
  }

  socket.on("connect", () => {
    console.log(socket.id);
  });

  return socket;
}
