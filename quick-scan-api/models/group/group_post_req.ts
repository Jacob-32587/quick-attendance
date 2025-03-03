import { validate } from "@babia/uuid-v7/validate";
import { Uuid, valUuid } from "../../uuid.ts";
import { z } from "npm:zod";

export const unique_id_settings = z.object({
  prompt_message: z.string().nullable(),
  min_length: z.number().positive().int().lte(64),
  max_length: z.number().positive().int().lte(64),
  required_for_managers: z.boolean(),
});

export const group_post_req = z.object({
  owner_id: z.custom<Uuid>((data) => valUuid(data)),
  group_name: z.string().min(4).max(64),
  group_description: z.string().max(4096).nullable(),
  unique_id_settings: unique_id_settings,
});

export type UniqueIdSettings = z.infer<typeof unique_id_settings>;
export type GroupPostReq = z.infer<typeof group_post_req>;
