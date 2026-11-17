param location string
param functionAppName string
param storageAccountName string
@secure()
param appiConnectionString string
param keyVaultUri string
param aiEndpoint string

resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'plan-${functionAppName}'
  location: location
  sku: { name: 'Y1', tier: 'Dynamic' } // Basic App Service Plan (Free Trial)
  properties: { reserved: true }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.11'
      appSettings: [
        { name: 'AzureWebJobsStorage', value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}' }
        { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'python' }
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appiConnectionString }
        { name: 'KEY_VAULT_URL', value: keyVaultUri }
        { name: 'AI_SERVICE_ENDPOINT', value: aiEndpoint }
      ]
    }
  }
}

output principalId string = functionApp.identity.principalId
