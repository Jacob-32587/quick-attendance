import { Context, Hono } from "npm:hono";
import { cors } from "npm:hono/cors";
import { jwt, verify } from "npm:hono/jwt";
import { logger } from "npm:hono/logger";
import HttpStatusCode from "./util/http_status_code.ts";
import { account, jwt_alg, jwt_secret } from "./endpoints/account.ts";
import { HTTPException } from "@hono/hono/http-exception";
import { Uuid, val_uuid, val_uuid_zod } from "./util/uuid.ts";
import { group } from "./endpoints/group.ts";
import { cli_flags } from "./util/cli_parse.ts";
import { attendance } from "./endpoints/attendance.ts";
import { Server } from "socket.io";
import { z } from "zod";
import { get_group_and_verify_user_type } from "./dal/group.ts";
import { UserType } from "./models/user_type.ts";
import qrcode from "qrcode-terminal";

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

// Uncomment the bellow line to see all requests
// app.use("*", logger());
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
  _: never;
}

interface ClientToServerEvents {
  attendanceTaken: () => void;
  error: (msg: string) => void;
}

interface InterServerEvents {
  ping: () => void;
}

interface SocketData {
  auth_data: AuthJwtPayload;
  group_id: Uuid;
}
export const ws = new Server<
  ServerToClientEvents,
  ClientToServerEvents,
  InterServerEvents,
  SocketData
>();

ws.on("connection", async (socket) => {
  try {
    // JWT authorization for user
    const auth_header = socket.handshake.auth.token;
    const group_id = socket.handshake.query.get("group_id");

    // Validate the given group id exists and is valid
    if (group_id === null || !val_uuid(group_id)) {
      socket.emit("error", "received malformed uuid");
      socket.disconnect(true);
      return;
    }

    // Validate the given auth header is given and valid
    if (auth_header === null || typeof auth_header !== "string" || auth_header === undefined) {
      socket.emit("error", "jwt header was the wrong type or not present");
      socket.disconnect(true);
      return;
    }
    const not_validated_jwt = (await verify(auth_header, jwt_secret, jwt_alg)) as unknown;
    const jwt = auth_jwt_payload.safeParse(not_validated_jwt);
    if (jwt.error) {
      socket.disconnect(true);
      socket.emit("error", "received malformed/expired jwt");
      return;
    }

    // Verify the user belongs to the group
    await get_group_and_verify_user_type(group_id, jwt.data.user_id, [
      UserType.Member,
      UserType.Manager,
    ]);

    socket.join(`${group_id}:${jwt.data.user_id}`);

    // Attach relevant data to the socket
    socket.data.auth_data = jwt.data;
    socket.data.group_id = group_id;
  } catch (e) {
    if (e instanceof HTTPException) {
      socket.emit("error", e.message);
    }
    if (socket.connected) {
      socket.disconnect();
    }
  }
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

if (port_num === 8080) {
  // Attempt and find the users ip addresss on their local network
  const address = Deno.networkInterfaces().find((x) =>
    (x.address.startsWith("192.168.") ||
      x.address.startsWith("172.")) &&
    (
      x.name.startsWith("en") ||
      x.name.startsWith("wl") ||
      x.name.startsWith("Wi-Fi")
    )
  )?.address;

  // If we are able to find an address print a QR code and the ip address to the command line
  if (address !== undefined) {
    qrcode.generate(address);
    console.log(`Local network ip address: ${address}`);
  } else {
    console.log("Unable to obtain ip address on local network");
  }
}

export const server = Deno.serve({
  hostname: "0.0.0.0",
  port: port_num,
}, handler);
