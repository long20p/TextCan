/*
  Function App Module - TextCan Infrastructure
  
  This module deploys:
  - App Service Plan (for Function App)
  - Function App for Key Generation Service
  - Application Insights and Log Analytics workspace
*/

// Parameters
param namingPrefix string
param namingSuffix string
param location string
param tags object
param storageAccountName string
@secure()
param storageAccountKey string
param functionAppName string
param funcKegenName string

// Resource names
var planKeyServiceName = 'plan-keyservice-${namingPrefix}-${namingSuffix}'
var appiKeyServiceName = 'appi-keyservice-${namingPrefix}-${namingSuffix}'
var loganKeyServiceName = 'logan-appi-keyservice-${namingPrefix}-${namingSuffix}'

// Create App Service Plan for Key Service (Function App)
resource planKeyServiceResource 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planKeyServiceName
  location: location
  tags: tags
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
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

// Create Log Analytics workspace for Key Service
resource loganKeyServiceResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: loganKeyServiceName
  location: location
  tags: tags
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

// Create Application Insights for Key Service
resource appiKeyServiceResource 'microsoft.insights/components@2020-02-02' = {
  name: appiKeyServiceName
  location: location
  tags: tags
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

// Create Key Service Function App
resource keyServiceResource 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  tags: tags
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountKey};EndpointSuffix=core.windows.net'
        }
      ]
    }
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

// Outputs
output functionAppName string = keyServiceResource.name
output functionAppId string = keyServiceResource.id
output functionAppUrl string = 'https://${functionAppName}.azurewebsites.net'
output functionAppPrincipalId string = keyServiceResource.identity.principalId
output funcKegenName string = funcKegenName
