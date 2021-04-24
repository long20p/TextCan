﻿using Amazon.DynamoDBv2;
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
        public DbContext(DbConfig dbConfig)
        {
            if (dbConfig?.EndpointUrl != null)
            {
                var config = new AmazonDynamoDBConfig
                {
                    ServiceURL = dbConfig.EndpointUrl
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
