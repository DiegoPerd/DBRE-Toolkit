// IaC/modules/keyvault.module.bicep
// Deploys an Azure Key Vault and a secret.

// === Parameters ===
@description('The location for the resources.')
param location string

@description('The base name for the resources.')
param baseName string

@description('The value of the secret to store.')
@secure()
param secretValue string

@description('The name of the secret to create')
param secretName string

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
  name: secretName
  properties: {
    value: secretValue
  }
}

// === Outputs ===
output keyVaultName string = keyVault.name
