import { z } from "zod";
import { QuickAttendanceJwtPayload } from "../main.ts";
import { val_uuid_zod } from "../util/uuid.ts";

export const group_invite_jwt_payload = z.object({
  iss: z.literal("quick-attendance-api"),
  sub: z.literal("group-invite"),
  aud: z.literal("quick-attendance-client"),
  group_name: z.string(),
  username: z.string(),
  group_id: val_uuid_zod(),
  owner_id: val_uuid_zod(),
  is_manager_invite: z.boolean(),
});

export type GroupInviteJwtPayload =
  & z.infer<typeof group_invite_jwt_payload>
  & QuickAttendanceJwtPayload;
