targetScope = 'resourceGroup'

param location string = resourceGroup().location
param lawName string
param appiName string
param storageAccountName string
param aiServiceName string
param keyVaultName string
param functionAppName string

module monitoring 'modules/monitoring.bicep' = {
  name: 'deploy-monitoring'
  params: {
    location: location
    lawName: lawName
    appiName: appiName
  }
}

module storage 'modules/storage.bicep' = {
  name: 'deploy-storage'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

module ai 'modules/ai.bicep' = {
  name: 'deploy-ai'
  params: {
    location: location
    aiServiceName: aiServiceName
  }
}

module keyvault 'modules/keyvault.bicep' = {
  name: 'deploy-keyvault'
  params: {
    location: location
    keyVaultName: keyVaultName
    aiServiceName: aiServiceName
  }
}

module functionApp 'modules/function.bicep' = {
  name: 'deploy-function'
  params: {
    location: location
    functionAppName: functionAppName
    storageAccountName: storage.outputs.storageAccountName
    appiConnectionString: monitoring.outputs.appiConnectionString
    keyVaultUri: keyvault.outputs.keyVaultUri
    aiEndpoint: ai.outputs.aiEndpoint
  }
}

module rbac 'modules/rbac.bicep' = {
  name: 'deploy-rbac'
  params: {
    keyVaultName: keyvault.outputs.keyVaultName
    principalId: functionApp.outputs.principalId // Conecta la Identidad Administrada de la Función
  }
}
