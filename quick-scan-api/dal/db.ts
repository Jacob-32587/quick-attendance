import { ContentfulStatusCode } from "@hono/hono/utils/http-status";

export interface DbErr {
  reason: string;
  status_code: ContentfulStatusCode;
}
export default await Deno.openKv("./db.sqlite");
