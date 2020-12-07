using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TextCan.Server.Models
{
    public class ContentModel
    {
        public string Text { get; set; }
        public DateTime? ExpireAt { get; set; }
    }
}
