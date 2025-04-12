import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";

export const attendance_put_req = z.object({
  group_id: val_uuid_zod(),
  user_ids: z.array(val_uuid_zod()),
  time_spoof_minute_offset: z.number().int().nullable().default(null),
});

export type AttendancePutReq = z.infer<typeof attendance_put_req>;
