/*
  Key Vault Module - TextCan Infrastructure
  
  This module deploys:
  - Key Vault
  - Secrets for Cosmos DB and Function App
*/

// Parameters
param location string
param tags object
param cosmosDbMasterKey string
param tenantId string
param keyVaultName string
param contentDbKeySecretName string
param funcKeySecretName string

// Create Key Vault
resource kvResource 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
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
    value: cosmosDbMasterKey
  }
}

// Create Key Service URL Secret in Key Vault (empty initially, will be populated later)
resource kvFuncKeyServiceSecretResource 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: kvResource
  name: funcKeySecretName
  properties: {
    attributes: {
      enabled: true
    }
    value: 'placeholder' // Will be updated by functionapp module
  }
}

// Outputs
output keyVaultName string = kvResource.name
output keyVaultId string = kvResource.id
output contentDbKeySecretName string = contentDbKeySecretName
output funcKeySecretName string = funcKeySecretName
