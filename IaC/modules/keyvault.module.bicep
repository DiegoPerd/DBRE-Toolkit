// IaC/modules/keyvault.module.bicep
// Deploys an Azure Key Vault and a secret.

// === Parameters ===
@description('The location for the resources.')
param location string

@description('The base name for the resources.')
param baseName string

@description('The value for the SQL admin login.')
param sqlAdminLogin string // <-- NEW

@description('The value of the SQL admin password.')
@secure()
param sqlAdminPassword string // <-- Renamed from secretValue


@description('The object ID of the user or principal to grant secret access to.')
param principalId string // user's ID

// === Variables ===
var keyVaultName = 'kv-${baseName}'

// === Resources ===
resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    // Define access policies
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: principalId // Grant access to the user deploying the template
        permissions: {
          secrets: [
            'get' // Permission to read secrets
          ]
        }
      }
    ]
  }
}

// Store the provided password as a secret in the Key Vault
resource sqlPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: 'sqlAdminPassword'
  properties: {
    value: sqlAdminPassword
  }
}

// Create a second secret for the SQL username
resource sqlUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: 'sqlAdminLogin' 
  properties: {
    value: sqlAdminLogin
  }
}

// === Outputs ===
output keyVaultName string = keyVault.name
