// IaC/modules/log-analytics.module.bicep
// Deploys a Log Analytics Workspace.

// === Parameters ===
@description('The location for the resources.')
param location string

@description('The base name for the resources.')
param baseName string


// === Variables ===
var logAnalyticsWorkspaceName = 'log-${baseName}-${uniqueString(resourceGroup().id)}'


// === Resources ===
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// === Outputs ===
output workspaceName string = logAnalyticsWorkspace.name
output workspaceId string = logAnalyticsWorkspace.id
