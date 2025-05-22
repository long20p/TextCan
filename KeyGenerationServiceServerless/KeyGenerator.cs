using System;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace TextCan.KeyGenerationService
{
    public static class KeyGenerator
    {
        private static readonly string Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

        [Function("KeyGenerator")]
        public static async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req,
            FunctionContext executionContext)
        {
            var log = executionContext.GetLogger("KeyGenerator");
            log.LogInformation("Generating unique key...");

            var rand = new Random();
            var strBuilder = new StringBuilder();
            for (int i = 0; i < 8; i++)
            {
                strBuilder.Append(Characters[rand.Next(Characters.Length)]);
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json");
            
            await response.WriteStringAsync(JsonSerializer.Serialize(new { key = strBuilder.ToString() }));
            
            return response;
        }
    }
}
