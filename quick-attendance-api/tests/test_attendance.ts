import { cleanup_test_step, init_test_step } from "../util/testing.ts";
import { URL } from "./main_test.ts";
import { create_users_and_group } from "./test_group_invite_and_join_test.ts";

Deno.test(
  async function take_attendance(t: Deno.TestContext) {
    const test_num = 3;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      await create_users_and_group(test_num);
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
