/*
  CosmosDB Module - TextCan Infrastructure
  
  This module deploys:
  - Cosmos DB account
  - Content database
  - Content container with appropriate partition key
*/

// Parameters
param namingPrefix string
param namingSuffix string
param location string
param tags object
param enableCosmosFreeTier bool = false

// Resource names
var cosmosDbAccountName = 'cosmos-content-${namingPrefix}-${namingSuffix}'
var contentDbName = 'TextCanContentDB'
var contentContainerName = 'Content'

// Create Cosmos DB account
resource cosmosDbAccountResource 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDbAccountName
  location: location
  tags: union(tags, {
    defaultExperience: 'Core (SQL)'
  })
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    enableFreeTier: enableCosmosFreeTier
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 1440
        backupRetentionIntervalInHours: 168
        backupStorageRedundancy: 'Geo'
      }
    }
    networkAclBypass: 'AzureServices'
    createMode: 'Default'
    capacity: {
      totalThroughputLimit: 4000
    }
  }
}

// Create database for content
resource cosmosDbContentDbResource 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosDbAccountResource
  name: contentDbName
  properties: {
    resource: {
      id: contentDbName
    }
  }
}

// Create container for content with autoscale settings
resource cosmosDbContainerResource 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDbContentDbResource
  name: contentContainerName
  properties: {
    resource: {
      id: contentContainerName
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/Key'
        ]
        kind: 'Hash'
        version: 2
      }
      uniqueKeyPolicy: {
        uniqueKeys: []
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: 4000
      }
    }
  }
}

// Outputs
output cosmosDbEndpoint string = cosmosDbAccountResource.properties.documentEndpoint
output cosmosDbAccountId string = cosmosDbAccountResource.id
output cosmosDbName string = contentDbName
output containerName string = contentContainerName
