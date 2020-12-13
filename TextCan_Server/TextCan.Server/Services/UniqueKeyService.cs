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

namespace TextCan.Server.Services
{
    public class UniqueKeyService : IUniqueKeyService
    {
        private HttpClient httpClient;
        private string keyServiceUrl;

        public UniqueKeyService(IOptions<KeyServiceConfig> config)
        {
            httpClient = new HttpClient();
            keyServiceUrl = config.Value.GetKeyUrl;
        }

        public async Task<string> GetUniqueKey()
        {
            var response = await httpClient.GetStringAsync(keyServiceUrl);
            var token = JObject.Parse(response)["key"];
            return token?.ToString();
        }
    }
}
