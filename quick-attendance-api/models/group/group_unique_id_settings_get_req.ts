import { z } from "zod";

export const group_unique_id_settings_get_req = z.object({
  account_invite_jwt: z.string(),
});

export type GroupUniqueIdSettingsGetReq = z.infer<
  typeof group_unique_id_settings_get_req
>;
