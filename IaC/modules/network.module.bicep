// IaC/network.module.bicep
// Defines the virtual network and a dedicated subnet.

// === Input Parameters ===
@description('Base name for the resources.')
param baseName string 

@description('The location/region where the resources will be deployed.')
param location string



// === Variables ===
// Generamos los nombres dinámicamente
var vnetName = 'vnet-${baseName}'
var subnetName = 'snet-${baseName}-mi' // snet for subnet, mi for Managed Instance

// === Resources ===
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName // Usamos la variable
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: vnet
  name: subnetName // Usamos la variable
  properties: {
    addressPrefix: '10.0.0.0/27'
    delegations: [
      {
        name: 'miDelegation'
        properties: {
          serviceName: 'Microsoft.Sql/managedInstances'
        }
      }
    ]
  }
}

// === Outputs ===
output subnetId string = subnet.id
