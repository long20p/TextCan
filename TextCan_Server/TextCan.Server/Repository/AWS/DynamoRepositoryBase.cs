using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace TextCan.Server.Repository.AWS
{
    public abstract class DynamoRepositoryBase<T> : IRepository<T>
    {
        protected DynamoRepositoryBase(IDynamoDbContext dbContext)
        {
            Context = dbContext;
        }

        protected IDynamoDbContext Context { get; }

        public async Task Add(T item)
        {
            await Context.Context.SaveAsync(item);
        }

        public Task Delete(string key)
        {
            throw new NotImplementedException();
        }

        public abstract Task EnsureTable();

        public async Task<T> GetItem(string key)
        {
            return await Context.Context.LoadAsync<T>(key);
        }

        public Task<IEnumerable<T>> Where(Expression<Func<T, bool>> predicate)
        {
            throw new NotImplementedException();
        }

        public IAsyncEnumerable<T> Where(string sqlQuery)
        {
            throw new NotImplementedException();
        }
    }
}
