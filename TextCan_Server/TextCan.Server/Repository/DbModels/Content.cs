using Amazon.DynamoDBv2.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TextCan.Server.Repository.DbModels
{
    [DynamoDBTable(nameof(Content))]
    public class Content
    {
        [DynamoDBHashKey]
        public string Key { get; set; }

        [DynamoDBProperty]
        public string Text { get; set; }

        [DynamoDBProperty]
        public string ExpireAt { get; set; }
    }
}
