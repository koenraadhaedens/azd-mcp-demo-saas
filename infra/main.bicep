targetScope = 'subscription'

// Parameters
@minLength(1)
@maxLength(64)
@description('Name of the environment to be used for resource naming')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Prefix for API resource names')
param apiNamePrefix string = 'fake-saas'

@secure()
@description('Demo API key for authentication')
param demoApiKey string

@description('Deploy Key Vault for secure secret storage')
param deployKeyVault bool = false

@description('Id of the service principal to assign to the container app')
param principalId string = ''

// Variables
var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  'azd-service-name': 'api'
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Container Apps Environment
module containerAppsEnvironment 'modules/env.bicep' = {
  scope: rg
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags
  }
}

// Azure Container Registry
module containerRegistry 'modules/acr.bicep' = {
  scope: rg
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    tags: tags
  }
}

// Optional: Key Vault for secure secret storage
module keyVault 'modules/kv.bicep' = if (deployKeyVault) {
  scope: rg
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
    demoApiKey: demoApiKey
  }
}

// Container App
module containerApp 'modules/containerapp.bicep' = {
  scope: rg
  params: {
    name: '${abbrs.appContainerApps}${apiNamePrefix}-${resourceToken}'
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.environmentId
    containerRegistryName: containerRegistry.outputs.name
    imageName: 'fake-saas-api:${environmentName}'
    environmentVariables: [
      {
        name: 'DEMO_API_KEY'
        value: demoApiKey
      }
      {
        name: 'AZURE_ENV_NAME'
        value: environmentName
      }
    ]
    targetPort: 3000
  }
}

// Outputs for azd
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP_NAME string = rg.name
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output AZURE_CONTAINER_APPS_ENVIRONMENT_NAME string = containerAppsEnvironment.outputs.name
output AZURE_CONTAINER_APP_NAME string = containerApp.outputs.name
output API_URL string = containerApp.outputs.fqdn
output API_ENDPOINTS object = {
  base: 'https://${containerApp.outputs.fqdn}'
  status: 'https://${containerApp.outputs.fqdn}/status'
  devices: 'https://${containerApp.outputs.fqdn}/devices'
  users: 'https://${containerApp.outputs.fqdn}/users'
  tickets: 'https://${containerApp.outputs.fqdn}/tickets'
  policies: 'https://${containerApp.outputs.fqdn}/policies'
  docs: 'https://${containerApp.outputs.fqdn}/docs'
}
