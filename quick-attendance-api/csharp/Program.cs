using static DenoUtil.DenoUtil;

public static class Program
{
    static void Main(string[] args)
    {
        // Choose the command to execute
        string? command_ret = args[0] switch
        {
            "get_alphanumeric_str" => get_alphanumeric_str(System.Convert.ToInt32(args[1])),
            _ => throw new Exception("Command not recognized"),
        };

        if (command_ret == null)
        {
            throw new NullReferenceException("Command returned null");
        }

        // Output JSON response with EOF
        Console.WriteLine(command_ret);
    }
}
