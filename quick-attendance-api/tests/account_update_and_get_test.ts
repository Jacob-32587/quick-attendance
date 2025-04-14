import { assert } from "@std/assert";
import AccountGetModel from "../models/account/account_get_model.ts";
import { cleanup_test_step, init_test_step, test_fetch, test_fetch_json } from "../util/testing.ts";
import { AccountPutReq } from "../models/account/account_put_req.ts";
import { ACCOUNT_AUTH_URL, create_and_login_test_users, URL } from "./main_test.ts";
import { HTTPException } from "@hono/hono/http-exception";
import HttpStatusCode from "../util/http_status_code.ts";

// Ensure user information can be updated
Deno.test(
  async function get_user_information(t: Deno.TestContext) {
    const test_num = 1;
    const sp = await init_test_step(test_num, t, URL(test_num));
    await t.step("test", async (_) => {
      // Create a login users
      const logged_in_users_jwts = await create_and_login_test_users(test_num);

      const update_user_information_promises: Promise<Response>[] = [];

      // Create and shuffle array of updates
      const random_account_array = [
        {
          "username": "Heisenburg23",
          "email": "hberg23@bb.com",
          "first_name": "Heisenburg",
        } as AccountPutReq,
        {
          "username": "Jesse P",
          "email": "jpinkman29@bb.com",
          "first_name": "Jesse",
          "last_name": "Pinkman",
        } as AccountPutReq,
        {
          "username": "Skyler W.",
          "email": "skylerw1989@bb.com",
          "first_name": "Skyler",
          "last_name": "White",
        } as AccountPutReq,
        {
          "username": "HankyS17",
          "email": "hankschrader_1987@bb.com",
          "first_name": "Hank",
          "last_name": "Schrader",
        } as AccountPutReq,
      ].map((value) => ({ value, sort: Math.random() }))
        .sort((a, b) => a.sort - b.sort)
        .map(({ value }) => value);

      let i = 0;
      for (const jwt of logged_in_users_jwts) {
        // Send upate request
        update_user_information_promises.push(
          test_fetch_json(ACCOUNT_AUTH_URL(test_num), "PUT", jwt, random_account_array[i]),
        );
        i++;
      }

      // Wait for updates to finish
      await Promise.all(update_user_information_promises);

      const get_updated_user_information_promises: Promise<Response>[] = [];
      // Get account information for each updated user
      for (const jwt of logged_in_users_jwts) {
        get_updated_user_information_promises.push(
          test_fetch_json(ACCOUNT_AUTH_URL(test_num), "GET", jwt, null, null, false),
        );
      }

      const updated_user_data_responses = await Promise.all(
        get_updated_user_information_promises,
      );

      const zipped_data = updated_user_data_responses.map((x, y) => ({
        get_data_res: x,
        user_data: random_account_array[y],
      }));

      // Ensure account information is correct
      for (const { get_data_res, user_data } of zipped_data) {
        const account = (await get_data_res.json()) as AccountGetModel;
        assert(account?.email == user_data?.email);
        assert(account?.username == user_data?.username);
        assert(account?.first_name == user_data?.first_name);
        assert(account?.last_name == user_data?.last_name);
      }

      await test_fetch_json(
        ACCOUNT_AUTH_URL(test_num),
        "PUT",
        logged_in_users_jwts[0],
        random_account_array[1],
        async (res) => {
          return res.status === HttpStatusCode.CONFLICT;
        },
        true,
        false,
      );
    });

    await cleanup_test_step(test_num, t, sp);
  },
);
