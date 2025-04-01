import { AttendancePostReq } from "../models/attendance/attendance_post_req.ts";
import { AttendancePutReq } from "../models/attendance/attendance_put_req.ts";
import { cleanup_test_step, init_test_step, test_fetch_json } from "../util/testing.ts";
import {
  ATTENDANCE_AUTH_URL,
  create_users_and_group,
  get_users_groups_and_accounts,
  URL,
} from "./main_test.ts";

Deno.test(
  "Creates a group and takes attendance",
  async function take_attendance(t: Deno.TestContext) {
    const test_num = 3;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      const create_group_ret = await create_users_and_group(test_num);
      const [rocco, maeve, henrik, indie] = await get_users_groups_and_accounts(
        create_group_ret.user_jwts,
        create_group_ret.group_id,
        test_num,
      );

      //#region Rocco begins attendance for the group
      await test_fetch_json(
        ATTENDANCE_AUTH_URL(test_num),
        "POST",
        rocco.account.jwt,
        { group_id: rocco.group.group_id } as AttendancePostReq,
      );
      //#endregion
      //#region Rocco takes attendance for maeve
      await test_fetch_json(
        ATTENDANCE_AUTH_URL(test_num),
        "PUT",
        rocco.group.jwt,
        {
          group_id: rocco.group.group_id,
          user_ids: [maeve.account.user_id],
        } as AttendancePutReq,
      );
      //#endregion
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
