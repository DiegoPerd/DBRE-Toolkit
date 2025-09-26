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

// === Module Deployments ===

// Deploy the network module.
module networkModule 'modules/network.module.bicep' = {
  name: 'networkDeployment'
  params:{
    location: location
    baseName: baseName    
  }
}

// Deploy the SQL Database module.
module sqlMiModule 'modules/sql-mi.module.bicep' = {
  name: 'sqlDeployment'
  params:{
    baseName: baseName
    location: location
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword
    subnetId: networkModule.outputs.subnetId
  }
}


// === Outputs ===

output deployedManagedInstanceName string = sqlMiModule.outputs.managedInstanceName
