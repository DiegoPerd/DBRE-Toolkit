// === Parámetros de Entrada ===
@description('Nombre base para los recursos. Se usará para generar nombres únicos.')
param baseName string = 'dbrelab'

@description('La ubicación donde se crearán los recursos.')
param location string = resourceGroup().location

@description('Nombre del administrador del servidor SQL.')
param sqlAdminLogin string

@description('Contraseña para el administrador. Debe ser compleja.')
@secure()
param sqlAdminPassword string


// === Variables Internas ===
// Nombres que construiremos para nuestros recursos
var sqlServerName = '${baseName}-sql-${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = '${baseName}-db'


// === Definición de Recursos ===

// 1. El Servidor Lógico de Azure SQL
resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
  }
}

// 2. La Base de Datos SQL dentro del servidor
resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-11-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    capacity: 1 
  }
}

// 3. Regla de Firewall para permitir acceso desde Azure
resource allowAzureIpsRule 'Microsoft.Sql/servers/firewallRules@2024-11-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}
