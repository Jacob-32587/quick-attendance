import { Hono } from "npm:hono";
import { zValidator } from "npm:@hono/zod-validator";
import * as dal from "../dal/group.ts";
import { group_post_req } from "../models/group/group_post_req.ts";
import { get_jwt_payload } from "../main.ts";
import HttpStatusCode from "../http_status_code.ts";

const group_base_path = "/group";
const auth_group_base_path = `/auth${group_base_path}`;

const group = new Hono();

group.post(
  auth_group_base_path,
  zValidator("json", group_post_req),
  async (ctx) => {
    const req = ctx.req.valid("json");
    await dal.create_group(get_jwt_payload(ctx).user_id, req);
    return ctx.text("", HttpStatusCode.OK);
  },
);

group.get(
  `${auth_group_base_path}/list`,
  async (ctx) => {
    const res = await dal.get_groups_for_account(get_jwt_payload(ctx).user_id);
    return ctx.json(res, HttpStatusCode.OK);
  },
);

export { group };
