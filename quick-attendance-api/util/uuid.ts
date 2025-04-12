import { z } from "zod";
import { uuidv7, V7Generator } from "uuidv7";
export type Uuid = string & { __uuid: void };

// Create a new version 7 Uuid
export function new_uuid(timestamp?: number) {
  if (timestamp != undefined) {
    const gen = new V7Generator();
    return gen.generateOrAbortCore(timestamp, 100)?.toString() as Uuid ?? "UUID gen failed";
  }
  return uuidv7() as Uuid;
}

// Validate uuid as version 7
export function val_uuid(maybe_uuid: string): maybe_uuid is Uuid {
  return Array.from(maybe_uuid).every((cs) => {
    const c = cs.charCodeAt(0);
    if ((c >= 97 && c <= 102) || (c >= 48 && c <= 57) || c === 45) {
      return true;
    }
    return false;
  });
}

export function get_uuid_unix_time(uuid: Uuid) {
  return parseInt(
    `${uuid[0]}${uuid[1]}${uuid[2]}${uuid[3]}${uuid[4]}${uuid[5]}${uuid[6]}${uuid[7]}${uuid[9]}${
      uuid[10]
    }${uuid[11]}${uuid[12]}`,
    16,
  );
}

export function get_maybe_uuid_time(uuid: Uuid | undefined | null) {
  if (uuid === undefined || uuid === null) {
    return uuid;
  }
  return get_uuid_time(uuid);
}

export function get_uuid_time(uuid: Uuid) {
  return new Date(get_uuid_unix_time(uuid));
}

export const val_uuid_zod = () => z.custom<Uuid>((d) => val_uuid(d));
