using Microsoft.Azure.Cosmos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace TextCan.Server.Repository.Azure
{
    public abstract class CosmosRepositoryBase<T> : IRepository<T>
    {
        protected CosmosRepositoryBase(ICosmosDbContext dbContext)
        {
            Context = dbContext;
        }

        protected ICosmosDbContext Context { get; }

        protected Database Database { get; set; }

        protected Container Container { get; set; }

        public virtual async Task EnsureTable()
        {
            var response = await Context.Client.CreateDatabaseIfNotExistsAsync("ApiServerDb");
            Database = response.Database;
        }

        public async Task Add(T item)
        {
            await Container.UpsertItemAsync<T>(item);
        }

        public async Task<T> GetItem(string key)
        {
            return await Container.ReadItemAsync<T>(key, new PartitionKey(key));
        }

        public Task<IEnumerable<T>> Where(Expression<Func<T, bool>> predicate)
        {
            throw new NotImplementedException();
        }
    }
}
