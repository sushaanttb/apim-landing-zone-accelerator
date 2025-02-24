// Execute this main file to depoy Azure AI Foundry resources in the basic security configuraiton
targetScope='subscription'
// Parameters
param resourceSuffix string

@minLength(2)
@maxLength(12)
@description('Name for the AI Foundry Hub resource, in 2-12 characters')
param aiHubName string

@description('Friendly name for your Azure AI Foundry Hub resource')
param aiHubFriendlyName string = 'AI Foundry Hub'

@description('Description of your Azure AI Foundry Hub as dispayed in AI Foundry')
param aiHubDescription string = 'This is an example AI Hub for use in Azure AI Foundry.'

@minLength(2)
@maxLength(12)
@description('Name for the AI Foundry project resource, in 2-12 characters')
param aiHubProjectName string

@description('Friendly name for your Azure AI Foundry Hub Project resource')
param aiHubprojectFriendlyName string = 'AI Foundry Hub Project'

@description('Description of your Azure AI Foundry Hub project as dispayed in AI Foundry')
param aiHubprojectDescription string = 'This is an example AI Hub project for use in Azure AI Foundry.'

@description('Azure region used for the deployment of all resources.')
param location string = deployment().location

@description('Set of tags to apply to all resources.')
param tags object = {}

// Variables
var aiHubResourceGroupName = 'rg-aih-${resourceSuffix}'

resource aiHubRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: aiHubResourceGroupName
  location: location
}

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies './aihub/dependent-resources.bicep' = {
  scope: resourceGroup(aiHubRG.name)
  name: 'dependencies-${aiHubName}-${resourceSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${aiHubName}${resourceSuffix}'
    keyvaultName: 'kv${aiHubName}${resourceSuffix}'
    applicationInsightsName: 'appi-${aiHubName}-${resourceSuffix}'
    containerRegistryName: 'cr${aiHubName}${resourceSuffix}'
    aiServicesName: 'ais${aiHubName}${resourceSuffix}'
    tags: tags
  }
}

module aiHub './aihub/ai-hub.bicep' = {
  scope: resourceGroup(aiHubRG.name)
  name: 'aih-${aiHubName}-${resourceSuffix}-deployment'
  params: {
    // workspace organization
    aiHubName: 'aih-${aiHubName}-${resourceSuffix}'
    aiHubFriendlyName: aiHubFriendlyName
    aiHubDescription: aiHubDescription
    location: location
    tags: tags

    // dependent resources
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
    applicationInsightsId: aiDependencies.outputs.applicationInsightsId
    containerRegistryId: aiDependencies.outputs.containerRegistryId
    keyVaultId: aiDependencies.outputs.keyvaultId
    storageAccountId: aiDependencies.outputs.storageId
  }
}

module aiHubProject './aihub/project.bicep' = {
  scope: resourceGroup(aiHubRG.name)
  name: 'aihp-${aiHubProjectName}-${resourceSuffix}-deployment'
  params: {
    aiHubId: aiHub.outputs.aiHubID
    aiHubProjectName: 'aihp-${aiHubProjectName}-${resourceSuffix}'
    aiHubProjectFriendlyName: aiHubprojectFriendlyName
    aiHubProjectDescription: aiHubprojectDescription
    location: location
    tags: tags
  }
}

module aiServicesModel './aihub/ai-services-model.bicep' = {
  scope: resourceGroup(aiHubRG.name)
  name: 'aism-${aiHubProjectName}-${resourceSuffix}-deployment'
  params: {
    aiHubId: aiHub.outputs.aiHubID
    aiHubProjectName: 'aihp-${aiHubProjectName}-${resourceSuffix}'
    aiHubProjectFriendlyName: aiHubprojectFriendlyName
    aiHubProjectDescription: aiHubprojectDescription
    location: location
    tags: tags
  }
}

output resourceSuffix string = resourceSuffix
output aiHubName string = aiHubName
output aiServicesId string = aiDependencies.outputs.aiservicesID
output aiServicesTarget string = aiDependencies.outputs.aiservicesTarget
output applicationInsightsId string = aiDependencies.outputs.applicationInsightsId
output containerRegistryId string = aiDependencies.outputs.containerRegistryId
output keyVaultId string = aiDependencies.outputs.keyvaultId
output storageAccountId string = aiDependencies.outputs.storageId
output projectId string = aiHubProject.outputs.id

