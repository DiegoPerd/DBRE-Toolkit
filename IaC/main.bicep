// Fichero principal que orquesta el despliegue

// Parámetros de entrada para el despliegue principal
@description('Nombre base para los recursos. Se usará para generar nombres únicos.')
param baseName string = 'dbrelab'

@description('La ubicación donde se crearán los recursos.')
param location string = resourceGroup().location

@description('Nombre del administrador del servidor SQL.')
param sqlAdminLogin string

@description('Contraseña para el administrador.')
@secure()
param sqlAdminPassword string


// Llamada al módulo de SQL
// Le pasamos los parámetros que necesita
module sqlModule 'sql.module.bicep' = {
  name: 'sqlDeployment' // Un nombre para esta ejecución del módulo
  params: {
    location: location
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword
    baseName: baseName
  }
}


// Podemos usar las salidas del módulo si las necesitamos
output deployedSqlServerName string = sqlModule.outputs.sqlServerName
