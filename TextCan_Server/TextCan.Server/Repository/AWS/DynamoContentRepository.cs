using Amazon.DynamoDBv2.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TextCan.Server.Repository.DbModels;

namespace TextCan.Server.Repository.AWS
{
    public class DynamoContentRepository : DynamoRepositoryBase<Content>, IContentRepository
    {
        public DynamoContentRepository(IDynamoDbContext context) : base(context)
        {
        }

        public override async Task EnsureTable()
        {
            var tableResponse = await Context.Client.ListTablesAsync();
            if(!tableResponse.TableNames.Contains(nameof(Content)))
            {
                var request = new CreateTableRequest
                {
                    TableName = nameof(Content),
                    KeySchema = new List<KeySchemaElement>
                    {
                        new KeySchemaElement
                        {
                            AttributeName = nameof(Content.Key),
                            KeyType = "HASH"
                        }
                    },
                    AttributeDefinitions = new List<AttributeDefinition>
                    {
                        new AttributeDefinition
                        {
                            AttributeName = nameof(Content.Key),
                            AttributeType = "S"
                        }
                    },
                    ProvisionedThroughput = new ProvisionedThroughput
                    {
                        ReadCapacityUnits = 5,
                        WriteCapacityUnits = 5
                    }
                };

                await Context.Client.CreateTableAsync(request);
            }
        }
    }
}
