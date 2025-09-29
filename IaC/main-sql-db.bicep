// Main Bicep file to orchestrate deployments.

// === Main deployment parameters ===
@description('Base name for the resources.')
param baseName string

@description('The location/region where the resources will be deployed.')
param location string = resourceGroup().location

@description('The administrator login name for the SQL server.')
param sqlAdminLogin string

@description('The administrator password for the SQL server.')
@secure()
param sqlAdminPassword string

@description('The public IP address of the client machine for firewall access.')
param clientIpAddress string 

// === Module Deployments ===

// Step 1: Deploy the Log Analytics Workspace
module logAnalyticsModule 'modules/log-analytics.module.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    location: location
    baseName: baseName
  }
}

module dcrModule 'modules/dcr.module.bicep' = {
  name: 'dcrDeployment'
  params:{
    baseName: baseName
    logAnalyticsWorkspaceName: logAnalyticsModule.outputs.workspaceName    
    location: location    
  }
}
// Deploy the SQL Database module.
module sqlModule 'modules/sql-db.module.bicep' = {
  name: 'sqlDeployment'  
  params:{
    location: location
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword
    baseName: baseName
    dataCollectionRuleId: dcrModule.outputs.dataCollectionRuleId
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.workspaceId    
    clientIpAddress: clientIpAddress
  }
}

// === Outputs ===


output sqlServerName string = sqlModule.outputs.sqlServerName

