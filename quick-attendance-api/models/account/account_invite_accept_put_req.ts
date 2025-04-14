import { z } from "zod";

export const account_invite_put_req = z.object({
  account_invite_jwt: z.string(),
  unique_id: z.string().min(1).max(64).nullable().default(null),
  accept: z.boolean(),
});

export type AccountInviteActionPutReq = z.infer<
  typeof account_invite_put_req
>;
