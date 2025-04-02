import { Context, Hono } from "npm:hono";
import { cors } from "npm:hono/cors";
import { jwt } from "npm:hono/jwt";
import { logger } from "npm:hono/logger";
import HttpStatusCode from "./util/http_status_code.ts";
import { account, jwt_alg, jwt_secret } from "./endpoints/account.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { Uuid } from "./util/uuid.ts";
import { group } from "./endpoints/group.ts";
import { cli_flags } from "./util/cli_parse.ts";
import { attendance } from "./endpoints/attendance.ts";
import { Server } from "socket.io";

const app = new Hono().basePath("/quick-attendance-api");

export { app };

export interface QuickAttendanceJwtPayload {
  [key: string]: unknown;
  iss: string;
  sub: string;
  aud: string;
  user_id: Uuid;
  exp: number;
  nbf: number;
  iat: number;
}

export interface AuthJwtPayload extends QuickAttendanceJwtPayload {
  iss: "quick-attendance-api";
  sub: "user-auth";
  aud: "quick-attendance-client";
}

app.use("*", logger());
app.use(
  cors({
    origin: "*",
    allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowHeaders: ["Authorization", "Content-Type"],
    credentials: true,
  }),
);

// Add auth middleware
app.use(
  "/auth/*",
  jwt({
    secret: jwt_secret,
    alg: jwt_alg,
  }),
);

export function get_jwt_payload(ctx: Context) {
  return ctx.get("jwtPayload") as QuickAttendanceJwtPayload;
}

// Adde global error handling middleware
app.onError((err, ctx) => {
  // Allow explicit HTTPExceptions to propagate through, otherwise return a generic
  // internal server error
  if (err instanceof HTTPException) {
    return ctx.json({ message: err.message, cause: err.cause }, err.status);
  } else if ("getResponse" in err) {
    // If an unauthorized error is being propagated we will allow it
    if (err.getResponse().status === HttpStatusCode.UNAUTHORIZED) {
      console.log(err.getResponse());
      console.log(err);
      ctx.res = err.getResponse();
      return ctx.res;
    }
  }

  console.log("Uncaught error: ", err);
  return ctx.json(
    "internal server error",
    HttpStatusCode.INTERNAL_SERVER_ERROR,
  );
});

const ws = new Server();

ws.on("connection", (socket) => {
  console.log(`socket ${socket.id} connected`);

  // socket.emit("hello", "world");
  //
  // socket.on("disconnect", (reason) => {
  //   console.log(`socket ${socket.id} disconnected due to ${reason}`);
  // });
});

app.get("/", (ctx: Context) => {
  return ctx.json({ utc_time: (new Date()).toUTCString() }, HttpStatusCode.OK);
});
app.route("", account);
app.route("", group);
app.route("", attendance);

const handler = ws.handler(async (req) => {
  return await app.fetch(req);
});

const port_num = parseInt(cli_flags["test-number"]) + 8080;

export const server = Deno.serve({
  port: port_num,
}, handler);
