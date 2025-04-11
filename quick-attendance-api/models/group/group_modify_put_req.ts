import { z } from "zod";

export const group_modify_put_req = z.object({
    groupName: z.array(z.string()).nonempty()
});