import * as uuidv7 from "@babia/uuid-v7";
import { z } from "zod";
export type Uuid = string & { __uuid: void };

// Create a new version 7 Uuid
export function new_uuid() {
  return uuidv7.generate() as Uuid;
}

// Validate uuid as version 7
export function val_uuid(maybe_uuid: string): maybe_uuid is Uuid {
  return uuidv7.validate(maybe_uuid);
}

export const val_uuid_zod = () => z.custom<Uuid>((d) => val_uuid(d));
