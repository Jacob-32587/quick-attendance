import { Hono } from "npm:hono";
import { newUuid, Uuid } from "../uuid.ts";
import { sign } from "npm:hono/jwt";
import { account_post_req_val } from "../models/account/account_post_req.ts";
import {
  account_login_post_req,
} from "../models/account/account_login_post_req.ts";
import { AccountLoginPostRes } from "../models/account/account_login_post_res.ts";
import { zValidator } from "npm:@hono/zod-validator";
import * as dal from "../dal/group.ts";
import { group_post_req } from "../models/group/group_post_req.ts";

const group_base_path = "/account";
const auth_group_base_path = `/auth${group_base_path}`;

const group = new Hono();

group.post(
  auth_group_base_path,
  zValidator("json", group_post_req),
  async (ctx) => {
    const req = ctx.req.valid("json");
    await dal.create_group(newUuid(), req);
  },
);

group.get(
  `${auth_group_base_path}/list`,
  zValidator("json", group_post_req),
  async (ctx) => {
    const req = ctx.req.valid("json");
    await dal.(newUuid(), req);
  },
);
