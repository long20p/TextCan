using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Amazon.DynamoDBv2.Model;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Configs;

namespace TextCan.Server.Repository
{
    public class DbContext : IDbContext
    {
        public DbContext(IOptions<DbConfig> dbConfig)
        {
            if (dbConfig?.Value?.EndpointUrl != null)
            {
                var config = new AmazonDynamoDBConfig
                {
                    ServiceURL = dbConfig.Value.EndpointUrl
                };
                Client = new AmazonDynamoDBClient(config);
            }
            else
            {
                Client = new AmazonDynamoDBClient();
            }
            Context = new DynamoDBContext(Client);
        }

        public IAmazonDynamoDB Client { get; }
        public IDynamoDBContext Context { get; }
    }
}
