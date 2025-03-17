import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";

export const attendance_post_req = z.object({
  group_id: val_uuid_zod(),
});

export type AttendancePostReq = z.infer<typeof attendance_post_req>;
