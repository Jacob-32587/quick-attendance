import { Context, Hono } from "npm:hono";
import { cors } from "npm:hono/cors";
import { jwt, verify } from "npm:hono/jwt";
import { logger } from "npm:hono/logger";
import HttpStatusCode from "./util/http_status_code.ts";
import { account, jwt_alg, jwt_secret } from "./endpoints/account.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { Uuid, val_uuid_zod } from "./util/uuid.ts";
import { group } from "./endpoints/group.ts";
import { cli_flags } from "./util/cli_parse.ts";
import { attendance, watch_attendance_ws } from "./endpoints/attendance.ts";
import { Server } from "socket.io";
import type { Socket } from "socket.io";
import { z } from "zod";

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

export const auth_jwt_payload = z.object({
  iss: z.literal("quick-attendance-api"),
  sub: z.literal("user-auth"),
  aud: z.literal("quick-attendance-client"),
  user_id: val_uuid_zod(),
  exp: z.number(),
  nbf: z.number(),
  iat: z.number(),
}).passthrough();

export type AuthJwtPayload = z.infer<typeof auth_jwt_payload>;

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

interface ServerToClientEvents {
  noArg: () => void;
  groupAttendance: (group_id: Uuid) => void;
  withAck: (d: string, callback: (e: number) => void) => void;
}

interface ClientToServerEvents {
  hello: () => void;
}

interface InterServerEvents {
  ping: () => void;
}

interface SocketData {
  auth_data: AuthJwtPayload;
}
const ws = new Server<ServerToClientEvents, ClientToServerEvents, InterServerEvents, SocketData>();

ws.on("connection", async (socket) => {
  // JWT authorization for user
  const auth_header = socket.handshake.auth.token;
  if (auth_header === null || typeof auth_header !== "string" || auth_header === undefined) {
    throw "JWT header invalid";
  }
  const not_validated_jwt = (await verify(auth_header, jwt_secret, jwt_alg)) as unknown;
  const jwt = auth_jwt_payload.safeParse(not_validated_jwt);
  if (jwt.error) {
    throw "Given JWT is not allowed for authorization";
  }

  // If valid JWT attach to socket data
  socket.data.auth_data = jwt.data;
  socket.on("groupAttendance", (group_id) => {
    console.log("Group id", group_id);
    if (socket.data.auth_data === undefined) {
      throw "Bad";
    }
    watch_attendance_ws(socket.data.auth_data.user_id, group_id);
  });
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
