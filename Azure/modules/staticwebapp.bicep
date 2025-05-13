/*
  Static Web App Module - TextCan Infrastructure
  
  This module deploys:
  - Static Web App for the TextCan UI
*/

// Parameters
param namingPrefix string
param namingSuffix string
param location string
param tags object

// Resource names
var staticWebAppName = 'static-ui-${namingPrefix}-${namingSuffix}'

// Create Static Web App
resource staticWebAppResource 'Microsoft.Web/staticSites@2022-09-01' = {
  name: staticWebAppName
  location: location
  tags: tags
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

// Outputs
output staticWebAppName string = staticWebAppResource.name
output staticWebAppId string = staticWebAppResource.id
output staticWebAppUrl string = 'https://${staticWebAppName}.azurestaticapps.net'
output defaultHostname string = staticWebAppResource.properties.defaultHostname
