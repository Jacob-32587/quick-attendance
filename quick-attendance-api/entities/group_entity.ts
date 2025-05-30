import { Uuid } from "../util/uuid.ts";

export interface GroupEntity {
  group_id: Uuid;
  owner_id: Uuid;
  group_name: string;
  group_description: string | null;
  current_attendance_id: Uuid | null;
  event_count: number;
  unique_id_settings: UniqueIdSettings | null;
}

export interface UniqueIdSettings {
  prompt_message: string | null;
  min_length: number;
  max_length: number;
  required_for_managers: boolean;
}
