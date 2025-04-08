import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";

export const group_put_request = z.object({
  group_id: val_uuid_zod(),
  group_name: z.string().min(4).max(64),
  group_description: z.string().max(4096).nullable().default(null),
  current_attendance_id: val_uuid_zod().nullable().default(null),
});

export type GroupPutRequest = z.infer<typeof group_put_request>;
