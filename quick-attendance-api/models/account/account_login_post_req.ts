import { z } from "npm:zod";

export const account_login_post_req = z.object({
  email: z.string().email(),
  password: z.string().max(64).min(8),
});

export type AccountLoginPostReq = z.infer<typeof account_login_post_req>;
