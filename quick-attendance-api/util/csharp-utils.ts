const get_csharp_exe_path = () => {
  if (Deno.build.os === "linux" && Deno.build.arch === "x86_64") {
    return "csharp/bin/Release/net8.0/linux-x64/publish/csharp";
  } else if (Deno.build.os === "linux" && Deno.build.arch === "aarch64") {
    return "csharp/bin/Release/net8.0/linux-arm64/publish/csharp";
  } else if (Deno.build.os === "windows" && Deno.build.arch === "x86_64") {
    return "csharp/bin/Release/net8.0/win-x64/publish/csharp";
  } else if (Deno.build.os === "darwin" && Deno.build.arch === "x86_64") {
    return "csharp/bin/Release/net8.0/osx-x64/publish/csharp";
  } else if (Deno.build.os === "darwin" && Deno.build.arch === "aarch64") {
    return "csharp/bin/Release/net8.0/osx-arm64/publish/csharp";
  }
  return null;
};

const csharp_exe_path = get_csharp_exe_path();

export async function exec_cs<T>(args: string[]) {
  if (csharp_exe_path === null) {
    return null;
  }
  const cmd = new Deno.Command(csharp_exe_path, {
    args: args,
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout, stderr } = await cmd.output();
  if (stderr.length !== 0) {
    console.error(new TextDecoder().decode(stderr));
  }
  // The command execution was successful, attempt to return JSON
  if (code === 0) {
    const json_text = new TextDecoder().decode(stdout);
    return JSON.parse(json_text) as T;
  } else {
    throw "Unable to decode JSON";
  }
}

interface GetAlphanumericStrReturn {
  random_chars: string;
}

export async function get_alphanumeric_str(length: number) {
  let output = await exec_cs<GetAlphanumericStrReturn>(["get_alphanumeric_str", `${length}`]);
  if (output === null) {
    // Execute some JS code to do the same thing
    output = { random_chars: "A" } as GetAlphanumericStrReturn;
  }
  return output;
}
