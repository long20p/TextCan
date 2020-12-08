using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TextCan.Server.Repository
{
    public interface IDbContext
    {
        IAmazonDynamoDB Client { get; }
        IDynamoDBContext Context { get; }
    }
}
