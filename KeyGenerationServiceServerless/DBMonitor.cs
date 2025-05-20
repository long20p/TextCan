using System;
using System.Text;
using System.Text.Json;
using System.Collections.Generic;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace TextCan.Monitors
{
    public static class DBMonitor
    {          
        [Function("DBMonitor")]
        [CosmosDBOutput(
            databaseName: "TextCanContentDB",
            containerName: "ItemLogs",
            Connection = "CosmosContent_DOCUMENTDB")]
        public static object Run(
            [CosmosDBTrigger(
            databaseName: "TextCanContentDB",
            containerName: "Content",
            Connection = "CosmosContent_DOCUMENTDB",
            LeaseContainerName = "leases",
            LeaseContainerPrefix = "ContentEventMonitor",
            CreateLeaseContainerIfNotExists = true)] IReadOnlyList<JsonElement> input,
            ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified " + input.Count);
                log.LogInformation("First document Id " + input[0].GetProperty("id").GetString());
            }            var logText = new StringBuilder();
            foreach (var item in input)
            {
                if (item.TryGetProperty("id", out JsonElement idElement))
                {
                    logText.Append(idElement.GetString());
                    logText.Append(",");
                }
            }

            return new { id = Guid.NewGuid().ToString(), Text = logText.ToString() };
        }
    }
}