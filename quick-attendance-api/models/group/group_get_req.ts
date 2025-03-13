import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";
import { UserType } from "../user_type.ts";

export const group_get_req = z.object({
  group_id: val_uuid_zod(),
  user_type: z.enum([UserType.Owner, UserType.Manager, UserType.Member]),
});

export type GroupGetReq = z.infer<typeof group_get_req>;
