/*
  TextCan Infrastructure Deployment - Main Module
  
  This is the main entry point for deploying TextCan infrastructure.
  It coordinates all module deployments and passes the necessary parameters.
*/

// Core parameters
param environment string = 'dev'
param enableCosmosFreeTier bool = false
param location string = resourceGroup().location

// Service naming conventions
var namingPrefix = 'textcan'
var namingSuffix = environment

// Resource names (calculated at deployment start)
var cosmosDbAccountName = 'cosmos-content-${namingPrefix}-${namingSuffix}'
var storageAccountName = 'stkeysvcfunct${namingPrefix}${namingSuffix}'
var functionAppName = 'func-keyservice-${namingPrefix}-${namingSuffix}'
var keyVaultName = 'kv-${namingPrefix}-${namingSuffix}'
var funcKegenName = 'KeyGenerator'
var contentDbKeySecretName = 'ContentDatabaseKey'
var funcKeySecretName = 'KeyServiceUrl'

// Define resource group level tags
var commonTags = {
  Application: 'TextCan'
  Environment: environment
  ManagedBy: 'Bicep'
}

// Deploy Cosmos DB resources
module cosmosDb 'modules/cosmosdb.bicep' = {
  name: 'cosmosDb-Deployment'
  params: {
    namingPrefix: namingPrefix
    namingSuffix: namingSuffix
    location: location
    tags: commonTags
    enableCosmosFreeTier: enableCosmosFreeTier
  }
}

// Get Cosmos DB master key using listKeys() in main.bicep
var cosmosDbMasterKey = listKeys(resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosDbAccountName), '2023-04-15').primaryMasterKey

// Deploy Key Vault
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVault-Deployment'
  params: {
    keyVaultName: keyVaultName
    contentDbKeySecretName: contentDbKeySecretName
    funcKeySecretName: funcKeySecretName
    location: location
    tags: commonTags
    cosmosDbMasterKey: cosmosDbMasterKey
    tenantId: subscription().tenantId
  }
}

// Deploy Storage for Function App
module storage 'modules/storage.bicep' = {
  name: 'storage-Deployment'
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: commonTags
  }
}

// Get Storage Account key using listKeys() in main.bicep
var storageAccountKey = listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2022-09-01').keys[0].value

// Deploy Function App with Key Generation Service
module keyGenerationService 'modules/functionapp.bicep' = {
  name: 'keyGenerationService-Deployment'
  params: {
    functionAppName: functionAppName
    funcKegenName: funcKegenName
    namingPrefix: namingPrefix
    namingSuffix: namingSuffix
    location: location
    tags: commonTags
    storageAccountName: storageAccountName
    storageAccountKey: storageAccountKey
    keyVaultName: keyVaultName
    cosmosDbKeySecretName: contentDbKeySecretName    
  }
}

// Get Function App key using listkeys() in main.bicep
var functionAppKey = listkeys(resourceId('Microsoft.Web/sites/host', functionAppName, 'default'), '2022-09-01').functionKeys.default

// Update the Key Vault secret with the actual Function App key
resource kvFuncKeyServiceSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${keyVaultName}/${funcKeySecretName}'
  properties: {
    attributes: {
      enabled: true
    }
    value: 'https://${functionAppName}.azurewebsites.net/api/${funcKegenName}?code=${functionAppKey}'
  }
  dependsOn: [
    keyVault
    keyGenerationService
  ]
}

// Deploy Content API
module contentApi 'modules/webapp.bicep' = {
  name: 'contentApi-Deployment'
  params: {
    namingPrefix: namingPrefix
    namingSuffix: namingSuffix
    location: location
    tags: commonTags
    cosmosDbEndpoint: cosmosDb.outputs.cosmosDbEndpoint
    keyVaultName: keyVaultName
    keyVaultContentDbKeySecretName: contentDbKeySecretName
    keyVaultFuncKeySecretName: funcKeySecretName
  }
}

// Deploy Static Web App for UI
module staticWebApp 'modules/staticwebapp.bicep' = {
  name: 'staticWebApp-Deployment'
  params: {
    namingPrefix: namingPrefix
    namingSuffix: namingSuffix
    location: location
    tags: commonTags
  }
}

// Grant Content API access to Key Vault
module keyVaultAccess 'modules/keyvaultaccess.bicep' = {
  name: 'keyVaultAccess-Deployment'
  params: {
    keyVaultName: keyVaultName
    principalId: contentApi.outputs.contentApiPrincipalId
    tenantId: subscription().tenantId
  }
}

module keyVaultAccessFn 'modules/keyvaultaccess.bicep' = {
  name: 'keyVaultAccess-FunctionApp'
  params: {
    keyVaultName: keyVaultName
    principalId: keyGenerationService.outputs.functionAppPrincipalId
    tenantId: subscription().tenantId
  }
}

// Output important endpoints and URLs
output contentApiUrl string = contentApi.outputs.contentApiUrl
output keyServiceUrl string = 'https://${functionAppName}.azurewebsites.net'
output staticUiUrl string = staticWebApp.outputs.staticWebAppUrl
output cosmosDbEndpoint string = cosmosDb.outputs.cosmosDbEndpoint
