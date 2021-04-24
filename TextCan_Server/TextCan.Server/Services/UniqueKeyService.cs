using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using TextCan.Server.Configs;
using Newtonsoft.Json.Linq;
using Microsoft.Extensions.Logging;

namespace TextCan.Server.Services
{
    public class UniqueKeyService : IUniqueKeyService
    {
        private ILogger<UniqueKeyService> logger;
        private HttpClient httpClient;
        private string keyServiceUrl;

        public UniqueKeyService(KeyServiceConfig config, ILogger<UniqueKeyService> logger)
        {
            this.logger = logger;
            httpClient = new HttpClient();
            keyServiceUrl = config.GetKeyUrl;
            logger.LogInformation($"Key service address: {keyServiceUrl}");
        }

        public async Task<string> GetUniqueKey()
        {
            var response = await httpClient.GetStringAsync(keyServiceUrl);
            var token = JObject.Parse(response)["key"];
            return token?.ToString();
        }
    }
}
