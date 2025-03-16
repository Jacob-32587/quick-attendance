namespace DenoUtil;

using System.Security.Cryptography;
using System.Text.Json;

public class DenoUtil
{
    private const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    /// <summary>
    /// Generate a random alphanumeric string of n length
    /// </summary>
    /// <param name="length">The number of characters in the resulting
    /// string</param>
    /// <returns>Generated alphanumeric string of n length</returns>
    public static string? get_alphanumeric_str(int length)
    {
        try
        {
            return JsonSerializer.Serialize(
                new { random_chars = RandomNumberGenerator.GetString(chars, length) }
            );
        }
        catch
        {
            return null;
        }
    }
}
