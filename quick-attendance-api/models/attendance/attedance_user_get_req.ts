import { z } from "zod";
import { get_week_num_of_month } from "../../util/time.ts";

export const attendance_user_get_req = z.object({
  year_num: z.number().nonnegative().int().default(new Date().getUTCFullYear()),
  month_num: z.number().nonnegative().int().default(new Date().getUTCMonth()),
  week_num: z.number().nonnegative().int().default(get_week_num_of_month(new Date())),
});

export type AttendanceUserGetReq = z.infer<typeof attendance_user_get_req>;
