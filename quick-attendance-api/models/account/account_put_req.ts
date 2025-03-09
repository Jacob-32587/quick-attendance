import { z } from "npm:zod";

export const account_put_req_val = z.object({
  username: z.string().max(32).min(2),
  email: z.string().email(),
  first_name: z.string().max(32),
  last_name: z.string().max(32).nullable().default(null),
});

export type AccountPutReq = z.infer<typeof account_put_req_val>;
