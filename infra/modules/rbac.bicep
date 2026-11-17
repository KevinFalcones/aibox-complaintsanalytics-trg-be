param keyVaultName string
param principalId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

// ID del rol "Key Vault Secrets User"
var kvSecretsUserRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, principalId, kvSecretsUserRole)
  scope: keyVault
  properties: {
    roleDefinitionId: kvSecretsUserRole
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
