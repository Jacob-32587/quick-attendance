import { z } from "zod";
import { val_uuid_zod } from "../../util/uuid.ts";

const group_get_req = z.object({
  group_id: val_uuid_zod(),
});

export type GroupGetReq = z.infer<typeof group_get_req>;
