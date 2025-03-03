# Quick Scan API
This is the API that the quick scan Fluter app uses authenticate user and save user data.

## Local development
- Install [Deno](https://deno.com/)
- Run `deno run --watch --allow-net --unstable-kv --allow-read --allow-write main.ts` in this directory
- Alternatively you can run `bash serv.sh` (on systems with bash)

## Endpoint documentation
- We are using `.http` files for endpoint documentation following the [IntelliJ](https://www.jetbrains.com/help/idea/exploring-http-syntax.html#) standard.
- When adding an endpoint you should provide at least 1 working test in the `quick-scan.http` file

## ERD
- The ERD diagram is contained within the `schema.drawio` file. This file can be viewed/modified with the standalone drawio software, however
the VSCode extension is recommended. The main advantage to VSCode is the support for symbol linking, meaning if you have an LSP drawio components can
be directly linked to relevant pieces of code.

