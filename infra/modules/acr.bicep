// Parameters
@description('Name of the Azure Container Registry')
param name string

@description('Location for the Azure Container Registry')
param location string = resourceGroup().location

@description('Tags to apply to the Azure Container Registry')
param tags object = {}

@description('SKU for the Azure Container Registry')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Standard'

// Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
    policies: {
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
  }
}

// Outputs
output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
output id string = containerRegistry.id
