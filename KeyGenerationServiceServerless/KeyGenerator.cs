using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace TextCan.KeyGenerationService
{
    public static class KeyGenerator
    {
        private static string Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

        [FunctionName("KeyGenerator")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("Generating unique key...");

            var rand = new Random();
            var strBuilder = new StringBuilder();
            for (int i = 0; i < 8; i++)
            {
                strBuilder.Append(Characters[rand.Next(Characters.Length)]);
            }

            return new JsonResult(new { key = strBuilder.ToString() });
        }
    }
}
