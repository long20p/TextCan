using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TextCan.Server.Repository.DbModels
{
    public class Content
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        public string Key { get; set; }

        public string Text { get; set; }

        public string ExpireAt { get; set; }
    }
}
