using Microsoft.Azure.Cosmos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TextCan.Server.Repository.Azure
{
    public interface ICosmosDbContext
    {
        CosmosClient Client { get; }
    }
}
