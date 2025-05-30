import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";
import { get_week_num_of_month } from "../../util/time.ts";

export const attendance_group_get_req = z.object({
  group_id: val_uuid_zod(),
  year_num: z.coerce.number().nonnegative().int().default(new Date().getUTCFullYear()),
  month_num: z.coerce.number().nonnegative().int().default(new Date().getUTCMonth()),
  week_num: z.coerce.number().nonnegative().int().default(get_week_num_of_month(new Date())),
});

export type AttendanceGroupGetReq = z.infer<typeof attendance_group_get_req>;
