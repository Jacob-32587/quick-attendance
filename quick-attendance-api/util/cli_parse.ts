import { parseArgs } from "@std/cli/parse-args";

export const cli_flags = parseArgs(Deno.args, {
  string: ["test-number"],
  default: { "test-number": "0" },
});
