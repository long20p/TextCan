using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TextCan.Server.Repository
{
    public class DbInitializer
    {
        public DbInitializer(IContentRepository contentRepository)
        {
            contentRepository.EnsureTable();
        }
    }
}
