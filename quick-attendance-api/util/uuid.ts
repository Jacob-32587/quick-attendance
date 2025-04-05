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

export function get_uuid_unix_time(uuid: Uuid) {
  return Number(
    `0x${uuid[0]}${uuid[1]}${uuid[2]}${uuid[3]}${uuid[4]}${uuid[5]}${uuid[6]}${uuid[7]}${uuid[9]}${
      uuid[10]
    }${uuid[11]}${uuid[12]}`,
  );
}

export function get_uuid_time(uuid: Uuid) {
  return new Date(get_uuid_unix_time(uuid));
}

export const val_uuid_zod = () => z.custom<Uuid>((d) => val_uuid(d));
