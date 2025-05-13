/*
  TextCan Infrastructure Deployment
  
  This Bicep file deploys the complete TextCan infrastructure to Azure:
  - Cosmos DB with Content container
  - Key Generation Service (Azure Function)
  - Content API (Web App)
  - Static Website (frontend UI)
  - Key Vault for secrets management
*/

// Core parameters
param environment string = 'dev'
param enableCosmosFreeTier bool = false
param location string = resourceGroup().location

// Service naming conventions
var namingPrefix = 'textcan'
var namingSuffix = environment

// Resource names
var kvName = 'kv-${namingPrefix}-${namingSuffix}'
var appContentApiName = 'app-contentapi-${namingPrefix}-${namingSuffix}'
var planKeyServiceName = 'plan-keyservice-${namingPrefix}-${namingSuffix}'
var keyServiceName = 'func-keyservice-${namingPrefix}-${namingSuffix}'
var staticUiName = 'static-ui-${namingPrefix}-${namingSuffix}'
var planContentApiName = 'plan-contentapi-${namingPrefix}-${namingSuffix}'
var cosmosDbAccountName = 'cosmos-content-${namingPrefix}-${namingSuffix}'

// Monitoring and logging resources
var appiContentApiName = 'appi-contentapi-${namingPrefix}-${namingSuffix}'
var loganAppiContentApiName = 'logan-appi-contentapi-${namingPrefix}-${namingSuffix}'
var appiKeyServiceName = 'appi-keyservice-${namingPrefix}-${namingSuffix}'
var loganKeyServiceName = 'logan-appi-keyservice-${namingPrefix}-${namingSuffix}'

// Storage account (required for Function App)
var storageAccountKeyServiceName = 'stkeysvcfunct${namingPrefix}${namingSuffix}'

// Database configurations
var contentDbName = 'TextCanContentDB'
var contentContainerName = 'Content'

// Key vault secrets
var contentDbKeySecretName = 'ContentDatabaseKey'
var funcKeySecretName = 'KeyServiceUrl'
var funcKegenName = 'KeyGenerator'

// Resource references
var cosmosAccResourceId = cosmosDbAccountResource.id
var dbKeySecretResourceId = kvContentDbSecretResource.id
var funcKeySecretResourceId = kvFuncKeyServiceSecretResource.id

// Tags that apply to all resources
var commonTags = {
  Application: 'TextCan'
  Environment: environment
  ManagedBy: 'Bicep'
}

// Create Cosmos DB account with the latest API version
resource cosmosDbAccountResource 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDbAccountName
  location: location
  tags: union(commonTags, {
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

// Create App Service Plan for Key Service (Function App)
resource planKeyServiceResource 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planKeyServiceName
  location: location
  tags: commonTags
  sku: {
    name: 'B1'  // Changed from Y1 to B1 to fix the Dynamic SKU with Linux compatibility issue
    tier: 'Basic' // Changed from Dynamic to Basic
  }
  kind: 'linux' // Changed from functionapp to linux
  properties: {
    reserved: true // Required for Linux
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    isXenon: false
    hyperV: false
  }
}

// Create Application Insights for Key Service
resource appiKeyServiceResource 'microsoft.insights/components@2020-02-02' = {
  name: appiKeyServiceName
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: loganKeyServiceResource.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableIpMasking: false
  }
}

// Create Log Analytics workspace for Key Service
resource loganKeyServiceResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: loganKeyServiceName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 120
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

// Create Storage Account for Key Service (Function App)
resource storageAccountKeyServiceResource 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountKeyServiceName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

// Create Key Service Function App
resource keyServiceResource 'Microsoft.Web/sites@2022-09-01' = {
  name: keyServiceName
  location: location
  tags: commonTags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: planKeyServiceResource.id
    reserved: true // Required for Linux
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appiKeyServiceResource.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appiKeyServiceResource.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountKeyServiceName};AccountKey=${storageAccountKeyServiceResource.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
    }
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

// Create Key Vault
resource kvResource 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: kvName
  location: location
  tags: commonTags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    publicNetworkAccess: 'Enabled'
    accessPolicies: []
  }
}

// Create Cosmos DB Key Secret in Key Vault
resource kvContentDbSecretResource 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: kvResource
  name: contentDbKeySecretName
  properties: {
    attributes: {
      enabled: true
    }
    value: listKeys(cosmosAccResourceId, '2023-04-15').primaryMasterKey
  }
}

// Create Key Service URL Secret in Key Vault
resource kvFuncKeyServiceSecretResource 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: kvResource
  name: funcKeySecretName
  properties: {
    attributes: {
      enabled: true
    }
    value: 'https://${keyServiceName}.azurewebsites.net/api/${funcKegenName}?code=${listkeys('${keyServiceResource.id}/host/default','2022-09-01').functionKeys.default}'
  }
}

// Add access policy to Key Vault for Content API
resource kvNameAdd 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  parent: kvResource
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: appContentApiResource.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

// Create App Service Plan for Content API
resource planContentApiResource 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planContentApiName
  location: location
  tags: commonTags
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

// Create Application Insights for Content API
resource appiContentApiResource 'microsoft.insights/components@2020-02-02' = {
  name: appiContentApiName
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: loganAppiContentApiResource.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Create Log Analytics workspace for Content API
resource loganAppiContentApiResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: loganAppiContentApiName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 120
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
  }
}

// Create Content API Web App
resource appContentApiResource 'Microsoft.Web/sites@2022-09-01' = {
  name: appContentApiName
  location: location
  tags: commonTags
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: planContentApiResource.id
    reserved: true
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'Database__EndpointUrl'
          value: cosmosDbAccountResource.properties.documentEndpoint
        }
        {
          name: 'Database__Key'
          value: '@Microsoft.KeyVault(SecretUri=${reference(dbKeySecretResourceId, '2023-02-01').secretUri})'
        }
        {
          name: 'KeyService__GetKeyUrl'
          value: '@Microsoft.KeyVault(SecretUri=${reference(funcKeySecretResourceId, '2023-02-01').secretUri})'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appiContentApiResource.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appiContentApiResource.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      healthCheckPath: '/health'
      cors: {
        allowedOrigins: [
          'https://${staticUiName}.azurestaticapps.net'
        ]
      }
    }
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

// Create Static UI Website
resource staticUiResource 'Microsoft.Web/staticSites@2022-09-01' = {
  name: staticUiName
  location: location
  tags: commonTags
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

// Output important endpoints and URLs
output contentApiUrl string = 'https://${appContentApiName}.azurewebsites.net'
output keyServiceUrl string = 'https://${keyServiceName}.azurewebsites.net'
output staticUiUrl string = 'https://${staticUiName}.azurestaticapps.net'
output cosmosDbEndpoint string = cosmosDbAccountResource.properties.documentEndpoint
