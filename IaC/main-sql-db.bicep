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

@description('The name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

// === Module Deployments ===

module dcrModule 'modules/dcr.module.bicep' = {
  name: 'dcrDeployment'
  params:{
    baseName: baseName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName    
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
  }
}


// === Outputs ===

// Module outputs can be used by other resources or returned by the deployment.
output deployedSqlServerName string = sqlModule.outputs.sqlServerName

