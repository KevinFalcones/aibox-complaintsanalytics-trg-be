param location string
param aiServiceName string

resource aiService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServiceName
  location: location
  kind: 'CognitiveServices'
  sku: { name: 'S0' }
  properties: {
    customSubDomainName: aiServiceName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

output aiEndpoint string = aiService.properties.endpoint
