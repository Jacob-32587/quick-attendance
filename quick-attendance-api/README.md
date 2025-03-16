# Quick Attendance API
This is the API that the quick attendance Fluter app uses authenticate user and save user data.

## Local development
- Install [Deno](https://deno.com/)
- Run `deno run --watch --allow-net --unstable-kv --allow-read --allow-write main.ts` in this directory
- Alternatively you can run `bash serv.sh` (on systems with bash)
- If you are calling on an endpoint that uses a C# util ensure that you have compiled according to the `comp_cs.sh` script
- When using a C# util function you must write the equivalent JS code and conditionally use JS when the C# executable fails. This
will happen if the application is deployed to managed deno services.

## Endpoint documentation
- We are using `.http` files for endpoint documentation following the [IntelliJ](https://www.jetbrains.com/help/idea/exploring-http-syntax.html#) standard.
- When adding an endpoint you should provide at least 1 working test in the `quick-attendance.http` file

## ERD
- The ERD diagram is contained within the `schema.drawio` file. This file can be viewed/modified with the standalone drawio software, however
the VSCode extension is recommended. The main advantage to VSCode is the support for symbol linking, meaning if you have an LSP drawio components can
be directly linked to relevant pieces of code.

## Testing
- You must run the `test.sh` script (or the Deno test command contained within it) and all tests must be passing before merging.
- If you make an endpoint you should probably create a new test, this is not a requirement though

