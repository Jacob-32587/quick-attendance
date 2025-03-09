import { QuickAttendanceJwtPayload } from "../../main.ts";
import { Uuid } from "../../util/uuid.ts";

export interface GroupInviteJwtPayload extends QuickAttendanceJwtPayload {
  iss: "quick-attendance-api";
  sub: "group-invite";
  aud: "quick-attendance-client";
  username: Uuid;
  group_id: Uuid;
  owner_id: Uuid;
}
