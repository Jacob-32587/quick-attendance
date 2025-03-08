import { z } from "npm:zod";

export const unique_id_settings = z.object({
  prompt_message: z.string().max(512).nullable().default(null),
  min_length: z.number().positive().int().default(1),
  max_length: z.number().positive().int().lte(64).default(64),
  required_for_managers: z.boolean().default(true),
}).refine((s) => {
  return s.min_length <= s.max_length;
});

export const group_post_req = z.object({
  group_name: z.string().min(4).max(64),
  group_description: z.string().max(4096).nullable(),
  unique_id_settings: unique_id_settings.nullable(),
});

export type UniqueIdSettings = z.infer<typeof unique_id_settings>;
export type GroupPostReq = z.infer<typeof group_post_req>;
