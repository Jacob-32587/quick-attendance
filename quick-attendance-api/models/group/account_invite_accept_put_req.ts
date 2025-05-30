import { z } from "zod";

export const account_invite_accept_put_req = z.object({
  account_invite_jwt: z.string(),
  unique_id: z.string().min(1).max(64).nullable().default(null),
});

export type AccountInviteAcceptPutReq = z.infer<
  typeof account_invite_accept_put_req
>;
