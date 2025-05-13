/*
  Key Vault Access Module - TextCan Infrastructure
  
  This module manages access policies for the Key Vault
*/

// Parameters
param keyVaultName string
param principalId string
param tenantId string

// Create access policy for the specified principal
resource kvAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: principalId
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

// Outputs
output policyId string = kvAccessPolicy.id
