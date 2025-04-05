import { assert } from "@std/assert/assert";
import { AttendancePostReq } from "../models/attendance/attendance_post_req.ts";
import { AttendancePutReq } from "../models/attendance/attendance_put_req.ts";
import { sleep } from "../util/sleep.ts";
import { cleanup_test_step, init_test_step, open_ws, test_fetch_json } from "../util/testing.ts";
import {
  ATTENDANCE_AUTH_URL,
  create_users_and_group,
  DOMAIN_AND_PORT,
  get_users_groups_and_accounts,
  GROUP_AUTH_URL,
  URL,
} from "./main_test.ts";
import { GroupPutRequest } from "../models/group/group_unique_id_settings_get_req.ts";
import { GroupGetReq } from "../models/group/group_get_req.ts";
import { AttendanceGetReq } from "../models/attendance/attedance_get_req.ts";
import { AttendanceGetRes } from "../models/attendance/attendance_get_res.ts";

Deno.test(
  "Creates a group and takes attendance",
  { sanitizeResources: false, sanitizeOps: false },
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

      let maeve_attendance_taken = false;
      let henrik_attendance_taken = false;
      let maeve_disconnect = false;
      let henrik_disconnect = false;

      //#region Maeve and Henrik open a websocket and listen for attendance recording
      const maeve_ws = await open_ws(
        DOMAIN_AND_PORT(test_num),
        maeve.account.jwt,
        maeve.group.group_id,
      );
      maeve_ws.on("attendanceTaken", () => {
        maeve_attendance_taken = true;
      }).on("disconnect", () => {
        maeve_disconnect = true;
      });

      const henrik_ws = await open_ws(
        DOMAIN_AND_PORT(test_num),
        henrik.account.jwt,
        henrik.group.group_id,
      );
      henrik_ws.on("attendanceTaken", () => {
        henrik_attendance_taken = true;
      }).on("disconnect", () => {
        henrik_disconnect = true;
      });

      //#endregion

      //#region Rocco takes attendance for maeve and Indie takes attendance for henrik
      await test_fetch_json(
        ATTENDANCE_AUTH_URL(test_num),
        "PUT",
        rocco.group.jwt,
        {
          group_id: rocco.group.group_id,
          user_ids: [maeve.account.user_id],
        } as AttendancePutReq,
      );
      await test_fetch_json(
        ATTENDANCE_AUTH_URL(test_num),
        "PUT",
        indie.group.jwt,
        {
          group_id: indie.group.group_id,
          user_ids: [henrik.account.user_id],
        } as AttendancePutReq,
      );
      //#endregion

      // Ensure WebSocket had a sufficient amount of time to respond
      // and check if both users received an attendance message
      await sleep(100);
      assert(maeve_attendance_taken);
      assert(henrik_attendance_taken);

      //#region Indie stops attendance taking for the group and ensure
      // users are disconnected
      await test_fetch_json(
        GROUP_AUTH_URL(test_num),
        "PUT",
        indie.group.jwt,
        {
          group_id: indie.group.group_id,
          group_name: indie.group.group_name,
          group_description: indie.group.group_description,
          current_attendance_id: null,
        } as GroupPutRequest,
      );
      await sleep(100);
      assert(maeve_disconnect);
      assert(henrik_disconnect);
      //#endregion

      //#region Indie checks the attendance for the week
      await test_fetch_json(
        `${ATTENDANCE_AUTH_URL(test_num)}/group?group_id=${indie.group.group_id}`,
        "GET",
        indie.group.jwt,
        null,
        async (body) => {
          const json = (await body.json()) as AttendanceGetRes;
          console.log(json);
          return json.attendance.length === 1 &&
            json.attendance[0].users.some((x) => x.user_id === henrik.account.user_id) &&
            json.attendance[0].users.some((x) => x.user_id === maeve.account.user_id);
        },
      );
      //#endregion
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
