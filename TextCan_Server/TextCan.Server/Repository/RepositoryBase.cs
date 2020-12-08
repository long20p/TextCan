using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace TextCan.Server.Repository
{
    public abstract class RepositoryBase<T> : IRepository<T>
    {
        public RepositoryBase(IDbContext context)
        {
            Context = context;
        }

        protected IDbContext Context { get; }

        public abstract Task EnsureTable();

        public async Task Add(T item)
        {
            await Context.Context.SaveAsync(item);
        }

        public async Task<T> GetItem(string key)
        {
            return await Context.Context.LoadAsync<T>(key);
        }

        public Task<IEnumerable<T>> Where(Expression<Func<T, bool>> predicate)
        {
            throw new NotImplementedException();
        }
    }
}
