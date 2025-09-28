// IaC/modules/monitoring.module.bicep
// Defines monitoring components for a SQL Database.

// === Parameters ===
@description('Base name for the resources.')
param baseName string 

@description('The name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

@description('The location for the monitoring resources.')
param location string



// === Variables ===
var dcrName = 'dcr-${baseName}' // Generate a unique DCR name



// === Resources ===

// 1. The Data Collection Rule (DCR)
resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: dcrName
  location: location
  kind: 'PlatformTelemetry'
  properties: {
    dataSources: {
      platformTelemetry: [
        {
          streams: [
            'Microsoft.Sql/servers/databases:Metrics-Group-All'
          ]
          name: 'pt-${baseName}'
        }        
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)
          name: logAnalyticsWorkspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft.Sql/servers/databases:Metrics-Group-All'
        ]
        destinations: [
          logAnalyticsWorkspaceName
        ]
      }
    ]
  }
}

// === Outputs ===
output dataCollectionRuleId string = dcr.id
