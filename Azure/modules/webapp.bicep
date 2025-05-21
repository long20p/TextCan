/*
  Web App Module - TextCan Infrastructure
  
  This module deploys:
  - App Service Plan (for Web App)
  - Web App for Content API
  - Application Insights and Log Analytics workspace
*/

// Parameters
param namingPrefix string
param namingSuffix string
param location string
param tags object
param cosmosDbEndpoint string
param keyVaultName string
param keyVaultContentDbKeySecretName string
param keyVaultFuncKeySecretName string

// Resource names
var appContentApiName = 'app-contentapi-${namingPrefix}-${namingSuffix}'
var planContentApiName = 'plan-contentapi-${namingPrefix}-${namingSuffix}'
var appiContentApiName = 'appi-contentapi-${namingPrefix}-${namingSuffix}'
var loganAppiContentApiName = 'logan-appi-contentapi-${namingPrefix}-${namingSuffix}'
var staticUiName = 'static-ui-${namingPrefix}-${namingSuffix}'

// Create App Service Plan for Content API
resource planContentApiResource 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planContentApiName
  location: location
  tags: tags
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

// Create Log Analytics workspace for Content API
resource loganAppiContentApiResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: loganAppiContentApiName
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

// Create Application Insights for Content API
resource appiContentApiResource 'microsoft.insights/components@2020-02-02' = {
  name: appiContentApiName
  location: location
  tags: tags
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

// Create Content API Web App
resource appContentApiResource 'Microsoft.Web/sites@2022-09-01' = {
  name: appContentApiName
  location: location
  tags: tags
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
          value: cosmosDbEndpoint
        }
        {
          name: 'Database__Key'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/${keyVaultContentDbKeySecretName}/)'
        }
        {
          name: 'KeyService__GetKeyUrl'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/${keyVaultFuncKeySecretName}/)'
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
          '*'
        ]
      }
    }
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

// Outputs
output contentApiName string = appContentApiResource.name
output contentApiId string = appContentApiResource.id
output contentApiUrl string = 'https://${appContentApiName}.azurewebsites.net'
output contentApiPrincipalId string = appContentApiResource.identity.principalId
