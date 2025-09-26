// IaC/sqlmi.module.bicep
// Defines the SQL Managed Instance resource.

// === Input Parameters ===
@description('Base name for the resources.')
param baseName string 

@description('The location/region where the resources will be deployed.')
param location string

@description('The administrator login name for the SQL Managed Instance.')
param sqlAdminLogin string

@description('The administrator password for the SQL Managed Instance.')
@secure()
param sqlAdminPassword string

@description('The resource ID of the subnet where the Managed Instance will be deployed.')
param subnetId string


// === Variables ===
var managedInstanceName = 'sqlmi-${baseName}-${uniqueString(resourceGroup().id)}'


// === Resources ===
resource sqlMI 'Microsoft.Sql/managedInstances@2023-08-01'={
  name: managedInstanceName
  location: location
  sku: {
    name: 'GP_Gen5' // General Purpose, Gen 5 hardware
    tier: 'GeneralPurpose'
    capacity: 4 // 4 vCores, ideal for dev/test
  }
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    subnetId: subnetId
    vCores: 4
    storageSizeInGB: 32 // The minimum is 32GB
  }
}


// === Outputs ===
output managedInstanceName string = sqlMI.name
