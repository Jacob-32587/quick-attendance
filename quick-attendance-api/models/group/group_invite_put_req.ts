import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";

export const group_invite_put_req = z.object({
  usernames: z.array(z.string().max(32).min(2)).nonempty(),
  group_id: val_uuid_zod(),
  is_manager_invite: z.boolean(),
});

export type GroupInvitePutReq = z.infer<typeof group_invite_put_req>;
