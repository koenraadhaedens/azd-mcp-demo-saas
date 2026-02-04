// Parameters
@description('Name of the Container Apps Environment')
param name string

@description('Location for the Container Apps Environment')
param location string = resourceGroup().location

@description('Tags to apply to the Container Apps Environment')
param tags object = {}

// Container Apps Environment
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// Log Analytics Workspace for Container Apps logging
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${name}-logs'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
    }
  }
}

// Outputs
output environmentId string = containerAppsEnvironment.id
output name string = containerAppsEnvironment.name
output domain string = containerAppsEnvironment.properties.defaultDomain
