@description('Name of the model to deploy')
param modelName string ='Phi-3-small-8k-instruct'

@description('Version of the model to deploy')
param modelVersion string = '5'

param deploymentName string = 'aiservices'

@allowed([
  'AI21 Labs'
  'Cohere'
  'Core42'
  'Meta'
  'Microsoft'
  'Mistral AI'
  'OpenAI'
])
@description('Model provider')
param modelPublisherFormat string = 'Microsoft'

@allowed([
    'GlobalStandard'
    'Standard'
    'GlobalProvisioned'
    'Provisioned'
])
@description('Model deployment SKU name')
param skuName string = 'GlobalStandard'

@description('Content filter policy name')
param contentFilterPolicyName string = 'Microsoft.DefaultV2'

@description('Model deployment capacity')
param capacity int = 1

// ToDo: to update with Project reference
// resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
//   name: deploymentName
//   parent:
//   sku: {
//     name: skuName
//     capacity: capacity
//   }
//   properties: {
//     model: {
//       format: modelPublisherFormat
//       name: modelName
//       version: modelVersion
//     }
//     raiPolicyName: contentFilterPolicyName == null ? 'Microsoft.Nill' : contentFilterPolicyName
//   }
// }
