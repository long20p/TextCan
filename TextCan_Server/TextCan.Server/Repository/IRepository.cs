using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace TextCan.Server.Repository
{
    public interface IRepository<T>
    {
        Task EnsureTable();
        Task Add(T item);
        Task<T> GetItem(string key);
        Task<IEnumerable<T>> Where(Expression<Func<T, bool>> predicate);
    }
}
