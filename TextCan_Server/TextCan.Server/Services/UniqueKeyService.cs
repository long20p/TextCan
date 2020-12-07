using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TextCan.Server.Services
{
    public class UniqueKeyService : IUniqueKeyService
    {
        private const string Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        private int keyLength;
        private Random rand;

        public UniqueKeyService(int keyLength)
        {
            this.keyLength = keyLength;
            rand = new Random();
        }

        public string GetUniqueKey()
        {
            var sb = new StringBuilder();
            for(int i = 0; i < keyLength; i++)
            {
                sb.Append(Characters[rand.Next(0, 62)]);
            }
            return sb.ToString();
        }
    }
}
