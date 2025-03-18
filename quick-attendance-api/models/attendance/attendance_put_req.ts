import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";

export const attendance_put_req = z.object({
  group_id: val_uuid_zod(),
  attendance_id: val_uuid_zod(),
  member_ids: z.array(val_uuid_zod()).nonempty().max(32),
});

export type AttendancePutReq = z.infer<typeof attendance_put_req>;
