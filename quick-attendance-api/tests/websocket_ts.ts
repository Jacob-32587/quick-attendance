import { cleanup_test_step, init_test_step } from "../util/testing.ts";
import { DOMAIN_AND_PORT, URL } from "./main_test.ts";
import { open_ws } from "../util/testing.ts";

// Denos resource sanitization must be disabled because the socket io client
// library does not clean up resources
Deno.test(
  "Creates a group",
  { sanitizeResources: false, sanitizeOps: false },
  async function invite_to_group_and_accept(t: Deno.TestContext) {
    const test_num = 4;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      // Open a websocket connection
      const socket = await open_ws(DOMAIN_AND_PORT(test_num));
      socket.disconnect();
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
