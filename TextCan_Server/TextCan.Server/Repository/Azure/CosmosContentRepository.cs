using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Repository.DbModels;

namespace TextCan.Server.Repository.Azure
{
    public class CosmosContentRepository : CosmosRepositoryBase<Content>, IContentRepository
    {
        public CosmosContentRepository(ICosmosDbContext context) : base(context)
        {
        }

        public override async Task EnsureTable()
        {
            await base.EnsureTable();
            var containerResponse = await Database.CreateContainerIfNotExistsAsync(nameof(Content), $"/{nameof(Content.Key)}");
            Container = containerResponse.Container;
        }
    }
}
