
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerInstance,

    [Parameter(Mandatory=$true)]
    [pscredential]$Credential, 

    [Parameter(Mandatory=$false)]
    [bool]$CreateJobs = $false
)

function Install-SqlScriptFromUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [Parameter(Mandatory=$true)]
        [string]$ServerInstance,

        [Parameter(Mandatory=$true)]
        [pscredential]$Credential

    )

    $fileName = Split-Path -Path $Url -Leaf
    $destinationPath = Join-Path -Path $env:TEMP -ChildPath $fileName
   
    Write-Host "Descargando '$fileName' en '$destinationPath'..."
    
    # Descargamos el fichero y lo dejamos en $env:temp
    try {
        Invoke-WebRequest -Uri $Url -OutFile $destinationPath -UseBasicParsing
        Write-Host "Descarga completada con éxito en: $destinationPath" -ForegroundColor Green
        # Instalamos en la instancia.
        try {                
            Invoke-Sqlcmd -InputFile $destinationPath -ServerInstance $ServerInstance -TrustServerCertificate  -Credential $Credential -ErrorAction Stop
            Write-Host "$filename Instalado correctamente." -ForegroundColor Green
        }
        catch {
            Write-Error "Falló la instalacion del fichero $filename. Error: $($_.Exception.Message)"
        }
    }
    catch {
        Write-Error "Falló la descarga del fichero $filename. Error: $($_.Exception.Message)"                       
    }        
}

function Install-OlaHallengrenJobs {
    param(        
        [Parameter(Mandatory=$true)]
        [string]$ServerInstance,

        [Parameter(Mandatory=$true)]
        [pscredential]$Credential,

        [Parameter(Mandatory=$true)]
        [object]$Configuration
    )

    Write-Host "Creando trabajos del Agente SQL de Ola Hallengren..." -ForegroundColor Yellow

    # --- 1. Crear el trabajo de Optimización de Índices ---
    $indexParams = $Configuration.olaHallengrenJobConfig.IndexOptimize
    $templatePath = Join-Path -Path $PSScriptRoot -ChildPath "Templates\Create-Ola-Jobs.sql"

    # Leemos la plantilla SQL
    $sqlTemplate = Get-Content -Path $templatePath -Raw

    # Reemplazamos los marcadores de posición
    $finalSql = $sqlTemplate `
        -replace '__FragmentationLow__', $indexParams.FragmentationLow `
        -replace '__FragmentationMedium__', $indexParams.FragmentationMedium `
        -replace '__FragmentationHigh__', $indexParams.FragmentationHigh `
        -replace '__FragmentationLevel1__', $indexParams.FragmentationLevel1 `
        -replace '__FragmentationLevel2__', $indexParams.FragmentationLevel2 `
        -replace '__LogToTable__', $indexParams.LogToTable

    # Ejecutamos el SQL final
    try {
        Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $finalSql -TrustServerCertificate -Credential $Credential  -ErrorAction Stop
        Write-Host "Trabajos creados y configurados correctamente." -ForegroundColor Green
    }
    catch {
        Write-Error "Falló la creación de los trabajos. Error: $($_.Exception.Message)"
    }

}


# --- Configuración ---
$projectRoot = Split-Path -Path $PSScriptRoot -Parent
$configPath = Join-Path -Path $projectRoot -ChildPath "config.json"
Write-Host "Cargando configuración desde: $configPath"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$sqlInstance = $ServerInstance

Write-Host "Iniciando instalación de herramientas en la instancia '$sqlInstance'..." -ForegroundColor Yellow

foreach ($tool in $config.toolsToInstall) {
    Write-Host "Procesando $($tool.name)..."
    Install-SqlScriptFromUrl -Url $tool.url -ServerInstance $sqlInstance -Credential $Credential
}

if ($CreateJobs){
    Install-OlaHallengrenJobs -ServerInstance $sqlInstance -Configuration $config -Credential $Credential
}



Write-Host "Instalación de herramientas finalizada." -ForegroundColor Yellow