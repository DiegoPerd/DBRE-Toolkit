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

@description('The Object ID of the principal to grant Key Vault access.')
param principalId string 


// === Module Deployments ===

// Deploy the Key Vault and store the SQL password in it
module keyVaultModule './modules/keyvault.module.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    baseName: baseName
    location: location        
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword
    principalId: principalId 
  }
}

// Deploy the Log Analytics Workspace
module logAnalyticsModule 'modules/log-analytics.module.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    baseName: baseName
    location: location    
  }
}

// Deploy the Data Collection Rule
module dcrModule 'modules/dcr.module.bicep' = {
  name: 'dcrDeployment'
  params:{
    baseName: baseName    
    location: location    
    logAnalyticsWorkspaceName: logAnalyticsModule.outputs.workspaceName    
  }
}

// Deploy the SQL Database module
module sqlModule 'modules/sql-db.module.bicep' = {
  name: 'sqlDeployment'  
  params:{
    baseName: baseName
    location: location
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword    
    dataCollectionRuleId: dcrModule.outputs.dataCollectionRuleId
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.workspaceId    
    clientIpAddress: clientIpAddress    
  }
}


// Deploy the Monitoring module
module monitoringModule 'modules/monitoring.module.bicep' = {
  name: 'monitoringDeployment'
  params: {
    alertRuleName: 'sql-high-cpu-alert'    
    targetResourceId: sqlModule.outputs.sqlDatabaseId    
    actionGroupName: 'dbre-ag'
  }
}

// === Outputs ===
output sqlServerName string = sqlModule.outputs.sqlServerName
output keyVaultName string = keyVaultModule.outputs.keyVaultName
