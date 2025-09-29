// IaC/sql.module.bicep
// Defines the SQL Server, SQL Database and firewall rule.

// === Input Parameters ===
@description('Base name for the resources.')
param baseName string 

@description('The location/region where the resources will be deployed.')
param location string 

@description('The administrator login name for the SQL server.')
param sqlAdminLogin string

@description('The administrator password for the SQL server.')
@secure()
param sqlAdminPassword string

@description('Id of the DCR for association with SQLDb')
param dataCollectionRuleId string 

@description('Id for Log Analytics Workspace')
param logAnalyticsWorkspaceId string

@description('The public IP address of the client machine for firewall access.')
param clientIpAddress string 


// === Variables ===
// Names for our resources
var sqlServerName = 'sql-${baseName}-${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'db-${baseName}'


// === Resources==

// Create the SQL Server instance
resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
  }
}

// Create the SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    capacity: 1 
  }
}

// === Resource Association ===
// This resource is deployed at the resource group level, but targets the database via the 'scope' property.
resource dcrAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = {
  name: 'dcra-${baseName}'
  scope: sqlDatabase 
  properties: {
    dataCollectionRuleId: dataCollectionRuleId
  }
}

// THE DIAGNOSTIC SETTING IS NOW CREATED HERE
resource sqlDbDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'sql-db-diagnostics'
  scope: sqlDatabase 
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Create the Firewall rule to allow Azure services to connect.
resource allowAzureIpsRule 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Create the Firewall rule to allow deployment machine to connect.
resource allowClientIpsRule 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'allowClientIpsRule'
  properties: {
    startIpAddress: clientIpAddress
    endIpAddress: clientIpAddress
  }
}


// === Outputs ===

output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name

