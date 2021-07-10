using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Configs;

namespace TextCan.Server.Repository.Azure
{
    public class CosmosDbContext : ICosmosDbContext
    {
        private ILogger<CosmosDbContext> logger;

        public CosmosDbContext(IOptions<DbConfig> config, ILogger<CosmosDbContext> logger)
        {
            this.logger = logger;
            Client = new CosmosClient(config.Value.EndpointUrl, config.Value.Key);
            logger.LogInformation($"DB endpoint: {config.Value.EndpointUrl}");
        }

        public CosmosClient Client { get; }
    }
}
