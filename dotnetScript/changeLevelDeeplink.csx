#r "nuget: System.Net.Http"
#r "nuget: System.Security.Cryptography.Algorithms"

using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Net.Http;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;

// Очистка консоли
Console.Clear();

static class EncryptionUtils
{
    private static readonly byte[] _iv =
    {
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16
    };

    public static string EncryptString(string plainText, string password)
    {
        using var aes = Aes.Create();
        aes.Key = DeriveKeyFromPassword(password);
        aes.IV = _iv;

        using var memoryStream = new MemoryStream();
        using var cryptoStream = new CryptoStream(memoryStream, aes.CreateEncryptor(), CryptoStreamMode.Write);
        cryptoStream.Write(Encoding.Unicode.GetBytes(plainText));
        cryptoStream.FlushFinalBlock();
        var array = memoryStream.ToArray();
        var base64String = Convert.ToBase64String(array);
        return Base64ToUrlSafeString(base64String);
    }

    private static byte[] DeriveKeyFromPassword(string password)
    {
        const int iterations = 100;
        var emptySalt = new byte[8];
        var hashMethod = HashAlgorithmName.SHA384;
        var passwordBytes = new Rfc2898DeriveBytes(password, emptySalt, iterations, hashMethod);
        return passwordBytes.GetBytes(32);
    }

    private static string Base64ToUrlSafeString(string base64String)
    {
        return base64String.Replace("+", "-").Replace("/", "_").Replace("=", "~");
    }

    private static string UrlSafeToBase64String(string urlSafe)
    {
        return urlSafe.Replace("-", "+").Replace("_", "/").Replace("~", "=");
    }
}

static class ShortioTools
{
    public static async Task<(HttpStatusCode StatusCode, string ShortUrl)> ShortenUrl(string urlToShorten, string originalUrl)
    {
        using (var client = new HttpClient())
        {
            var url = "https://api.short.io/links/";
            client.DefaultRequestHeaders.Add("accept", "application/json");
            client.DefaultRequestHeaders.Add("Authorization", "sk_zA85imrMYZAOLq05");

            var jsonContent = $"{{\"originalURL\":\"{urlToShorten}\"}}";
            var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

            var response = await client.PostAsync(url + originalUrl, content);

            var responseContent = await response.Content.ReadAsStringAsync();

            using (JsonDocument doc = JsonDocument.Parse(responseContent))
            {
                var shortUrl = doc.RootElement.GetProperty("shortURL").GetString();
                return (response.StatusCode, shortUrl);
            }
        }
    }
}

// Основная логика скрипта

Console.Write("Enter ClientId: ");
var clientId = Console.ReadLine();

Console.Write("\nEnter Level Number for restore: ");
var level = Console.ReadLine();

var urlParams = $"lv={level}&id={clientId}";
var encryptedParams = EncryptionUtils.EncryptString(urlParams, "fHXULAxj4u");
var fullEncryptUrl = $"fb354504776513609://levelprogress?{encryptedParams}";

Console.WriteLine("\nDeepLink to restore progress: " + fullEncryptUrl);

var urlToShorten = $"{fullEncryptUrl}";
var originalUrl = "lnk_4THD_ZioY8x854syQAEU3gUTK3";

var result = await ShortioTools.ShortenUrl(urlToShorten, originalUrl);
Console.WriteLine($"---------------------------------------------------------------");
Console.WriteLine($"Status code = {result.StatusCode}, ShortLink = {result.ShortUrl}");
