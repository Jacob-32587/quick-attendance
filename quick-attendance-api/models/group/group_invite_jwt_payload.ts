import { QuickScanJwtPayload } from "../../main.ts";
import { Uuid } from "../../util/uuid.ts";

export interface GroupInviteJwtPayload extends QuickScanJwtPayload {
  iss: "quick-scan-api";
  sub: "group-invite";
  aud: "quick-scan-client";
  username: Uuid;
  group_id: Uuid;
  owner_id: Uuid;
}
