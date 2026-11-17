param location string
param keyVaultName string
param aiServiceName string // Get the name not key

// 1. Reference to resource IA create in another module
resource aiService 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServiceName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource aiSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'AiServiceKey'
  properties: {
    // 2. Extract key directly in memory
    value: aiService.listKeys().key1 
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultName string = keyVault.name
