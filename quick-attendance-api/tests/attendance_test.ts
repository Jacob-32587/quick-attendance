import { assert } from "@std/assert/assert";
import { AttendancePostReq } from "../models/attendance/attendance_post_req.ts";
import { AttendancePutReq } from "../models/attendance/attendance_put_req.ts";
import { sleep } from "../util/sleep.ts";
import { cleanup_test_step, init_test_step, open_ws, test_fetch_json } from "../util/testing.ts";
import {
  additonal_user_array,
  ATTENDANCE_AUTH_URL,
  create_users_and_group,
  DOMAIN_AND_PORT,
  get_users_groups,
  get_users_groups_and_accounts,
  GROUP_AUTH_URL,
  invite_additonal_users,
  URL,
  user_array,
} from "./main_test.ts";
import { GroupPutRequest } from "../models/group/group_unique_id_settings_get_req.ts";
import { AttendanceGroupGetRes } from "../models/attendance/attendance_group_get_res.ts";
import { AttendanceUserGetRes } from "../models/attendance/attendance_user_get_res.ts";
import { GroupGetRes } from "../models/group/group_get_res.ts";
import { get_maybe_uuid_time, get_uuid_time, Uuid } from "../util/uuid.ts";

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

      //#region Indie stops attendance taking for the group and ensures
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
          time_spoof_minute_offset: 60,
        } as GroupPutRequest,
      );
      await sleep(100);
      assert(maeve_disconnect);
      assert(henrik_disconnect);

      {
        const updated_group = await get_users_groups(
          [indie.group.jwt],
          indie.group.group_id,
          test_num,
        );
        assert(updated_group[0].current_attendance_id === null);
      }

      //#endregion

      //#region Start taking attendance again but henrik is not present and no users connect to the websocket
      await test_fetch_json(
        ATTENDANCE_AUTH_URL(test_num),
        "POST",
        rocco.account.jwt,
        { group_id: rocco.group.group_id, time_spoof_minute_offset: 120 } as AttendancePostReq,
      );
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
        GROUP_AUTH_URL(test_num),
        "PUT",
        rocco.group.jwt,
        {
          group_id: rocco.group.group_id,
          group_name: rocco.group.group_name,
          group_description: rocco.group.group_description,
          current_attendance_id: null,
          time_spoof_minute_offset: 180,
        } as GroupPutRequest,
      );
      //#endregion

      //#region Indie checks the attendance for the week
      await test_fetch_json(
        `${ATTENDANCE_AUTH_URL(test_num)}/group?group_id=${indie.group.group_id}`,
        "GET",
        indie.group.jwt,
        null,
        async (body) => {
          const json = (await body.json()) as AttendanceGroupGetRes;
          return json.attendance.length === 2 &&
            json.attendance[0].users.some((x) => x.user_id === henrik.account.user_id) &&
            json.attendance[0].users.some((x) => x.user_id === maeve.account.user_id) &&
            json.attendance[1].users.some((x) => x.user_id !== henrik.account.user_id) &&
            json.attendance[1].users.some((x) => x.user_id === maeve.account.user_id);
        },
      );

      {
        const updated_group = await get_users_groups(
          [indie.group.jwt],
          indie.group.group_id,
          test_num,
        );
        assert(updated_group[0].current_attendance_id === null);
      }
      //#endregion

      //#region Maeve and henrik check there attendance for the week
      let most_recent_attendance_id: Uuid | null = null;
      await test_fetch_json(
        `${ATTENDANCE_AUTH_URL(test_num)}/user`,
        "GET",
        maeve.group.jwt,
        null,
        async (body) => {
          const json = (await body.json()) as AttendanceUserGetRes;
          return json.attendance.length === 1 &&
            json.attendance[0].attendance_records.length === 2 &&
            json.attendance[0].group.group_id === maeve.group.group_id &&
            json.attendance[0].attendance_records[0].present === true &&
            json.attendance[0].attendance_records[1].present === true;
        },
      );
      await test_fetch_json(
        `${ATTENDANCE_AUTH_URL(test_num)}/user`,
        "GET",
        henrik.group.jwt,
        null,
        async (body) => {
          const json = (await body.json()) as AttendanceUserGetRes;

          if (
            json.attendance[0].attendance_records[0].attendance_id >
              json.attendance[0].attendance_records[1].attendance_id
          ) {
            most_recent_attendance_id = json.attendance[0].attendance_records[0].attendance_id;
          } else {
            most_recent_attendance_id = json.attendance[0].attendance_records[1].attendance_id;
          }
          return json.attendance.length === 1 &&
            json.attendance[0].group.group_id === henrik.group.group_id &&
            json.attendance[0].group.group_id === maeve.group.group_id &&
            json.attendance[0].attendance_records[0].present === true &&
            json.attendance[0].attendance_records[1].present === false;
        },
      );
      //#endregion

      //#region Check the most recent attendance id
      await test_fetch_json(
        GROUP_AUTH_URL(test_num) +
          `?group_id=${rocco.group.group_id}`,
        "GET",
        rocco.group.jwt,
        null,
        async (res) => {
          const group = (await res.json()) as GroupGetRes;
          const pass = group.last_attendance_date?.toString() ===
            get_maybe_uuid_time(most_recent_attendance_id)?.toISOString();

          if (!pass) {
            console.log("Most recent attendance not correct: ", group);
          }
          return pass;
        },
      );
      //#endregion

      // Invite more users to the group and take attendance for the group at random spoof intervals,
      // with each user choosing to attend or not randomly
      const additonal_users = await invite_additonal_users(
        test_num,
        rocco.account.jwt,
        rocco.group.group_id,
      );

      additonal_users.push(henrik.account);
      additonal_users.push(maeve.account);

      let users = pair_array(additonal_users);

      for (let i = 1; i <= 20; i++) {
        // Shuffle order of users
        users = users.map((value) => ({ value, sort: Math.random() }))
          .sort((a, b) => a.sort - b.sort)
          .map(({ value }) => value);

        const rand_start_time_offset = rand_int_from_interval(1, 360) * i * -1;
        const rand_end_time_offest = rand_start_time_offset + rand_int_from_interval(20, 90);

        // Start attendance
        await test_fetch_json(
          ATTENDANCE_AUTH_URL(test_num),
          "POST",
          rocco.account.jwt,
          {
            group_id: rocco.group.group_id,
            time_spoof_minute_offset: rand_start_time_offset,
          } as AttendancePostReq,
        );

        // Choose 50/50 that the user will attend, both rocco
        // and indie will be taking attendance
        for (const user of users) {
          if (Math.round(Math.random()) === 1) {
            await test_fetch_json(
              ATTENDANCE_AUTH_URL(test_num),
              "PUT",
              rocco.group.jwt,
              {
                group_id: rocco.group.group_id,
                user_ids: [user[0]?.user_id ?? ""],
              } as AttendancePutReq,
            );
          }
          if (Math.round(Math.random()) === 1) {
            await test_fetch_json(
              ATTENDANCE_AUTH_URL(test_num),
              "PUT",
              rocco.group.jwt,
              {
                group_id: rocco.group.group_id,
                user_ids: [user[1]?.user_id ?? ""],
              } as AttendancePutReq,
            );
          }
        }

        await test_fetch_json(
          GROUP_AUTH_URL(test_num),
          "PUT",
          rocco.group.jwt,
          {
            group_id: rocco.group.group_id,
            group_name: rocco.group.group_name,
            group_description: rocco.group.group_description,
            current_attendance_id: null,
            time_spoof_minute_offset: rand_end_time_offest,
          } as GroupPutRequest,
        );
      }
    });

    function rand_int_from_interval(min: number, max: number) { // min and max included
      return Math.floor(Math.random() * (max - min + 1) + min);
    }

    function pair_array<T>(arr: T[]) {
      const res = [];
      for (let i = 0; i < arr.length; i += 2) {
        res.push([arr[i], arr[i + 1] ?? null]);
      }
      return res;
    }

    await cleanup_test_step(test_num, t, sp);
  },
);
