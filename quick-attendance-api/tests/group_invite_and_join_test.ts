import { cleanup_test_step, init_test_step } from "../util/testing.ts";
import { create_users_and_group, URL } from "./main_test.ts";

// Ensure users can be invited to groups and accept invites
Deno.test(
  "Creates a group",
  async function invite_to_group_and_accept(t: Deno.TestContext) {
    const test_num = 2;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      await create_users_and_group(test_num);
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
