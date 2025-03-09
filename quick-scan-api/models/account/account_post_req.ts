import { z } from "npm:zod";

export const account_post_req_val = z.object({
  username: z.string().max(32).min(2),
  email: z.string().email(),
  first_name: z.string().max(32),
  last_name: z.string().max(32).nullable().default(null),
  password: z.string().max(64).min(8),
});

export type AccountPostReq = z.infer<typeof account_post_req_val>;
