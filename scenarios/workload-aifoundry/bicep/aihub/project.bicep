@description('Resource ID of the AI Hub in which to create the project')
param aiHubId string

@description('AI hub Project name')
param aiHubProjectName string

@description('AI hub Project display name')
param aiHubProjectFriendlyName string = aiHubProjectName

@description('AI hub Project description')
param aiHubProjectDescription string

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

resource aiHubProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiHubProjectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiHubProjectFriendlyName
    description: aiHubProjectDescription
    hubResourceId: aiHubId
  }
  kind: 'project'
}

@description('ID of the deployed AI Hub project resource.')
output id string = aiHubProject.id
@description('Name of the deployed AI Hub project resource.')
output name string = aiHubProject.name
