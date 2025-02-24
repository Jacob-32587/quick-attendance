import * as uuidv7 from "@babia/uuid-v7";
export type Uuid = string & { __uuid: void };

// Create a new version 7 Uuid
export function newUuid() {
  return uuidv7.generate() as Uuid;
}

// Validate uuid as version 7
export function valUuid(maybe_uuid: string): maybe_uuid is Uuid {
  return uuidv7.validate(maybe_uuid);
}
