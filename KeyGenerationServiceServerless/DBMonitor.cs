using System;
using System.Text;
using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace TextCan.Monitors
{
    public static class DBMonitor
    {
        [FunctionName("DBMonitor")]
        public static void Run([CosmosDBTrigger(
            databaseName: "TextCanContentDB",
            collectionName: "Content",
            ConnectionStringSetting = "CosmosContent_DOCUMENTDB",
            LeaseCollectionName = "leases",
            LeaseCollectionPrefix = "ContentEventMonitor",
            CreateLeaseCollectionIfNotExists = true)]IReadOnlyList<Document> input,
            			[CosmosDB(
			                databaseName: "TextCanContentDB",
			                collectionName: "ItemLogs",
                ConnectionStringSetting = "CosmosContent_DOCUMENTDB")] out dynamic document,
            ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified " + input.Count);
                log.LogInformation("First document Id " + input[0].Id);
            }

            var logText = new StringBuilder();
            foreach (var item in input)
            {
                logText.Append(item.Id);
                logText.Append(",");
            }

            document = new { id = "LogId", Text = logText.ToString() };
        }
    }
}
