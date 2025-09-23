function Install-SqlScriptFromUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [Parameter(Mandatory=$true)]
        [string]$ServerInstance
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
            Invoke-Sqlcmd -InputFile $destinationPath -ServerInstance "localhost" -TrustServerCertificate
            Write-Host "$filename Instalado correctamente." -ForegroundColor Green
        }
        catch {
            Write-Error "Falló la instalacion del fichero $filename. Error: $_"
        }
    }
    catch {
        Write-Error "Falló la descarga del fichero $filename. Error: $_"                       
    }        
}


# --- Configuración ---
$sqlInstance = "localhost"
$tools = @(
    # --- Ola Hallengren ---
    "https://raw.githubusercontent.com/olahallengren/sql-server-maintenance-solution/master/CommandExecute.sql",
    "https://raw.githubusercontent.com/olahallengren/sql-server-maintenance-solution/master/CommandLog.sql",
    "https://raw.githubusercontent.com/olahallengren/sql-server-maintenance-solution/master/DatabaseIntegrityCheck.sql",
    "https://raw.githubusercontent.com/olahallengren/sql-server-maintenance-solution/master/IndexOptimize.sql",

    # --- Adam Machanic ---
    "https://raw.githubusercontent.com/amachanic/sp_whoisactive/master/sp_WhoIsActive.sql",

    # --- Brent Ozar (First Responder Kit) ---
    "https://raw.githubusercontent.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/main/sp_Blitz.sql",
    "https://raw.githubusercontent.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/main/sp_BlitzCache.sql"
)



Write-Host "Iniciando instalación de herramientas en la instancia '$sqlInstance'..." -ForegroundColor Yellow

foreach ($toolUrl in $tools) {
    Install-SqlScriptFromUrl -Url $toolUrl -ServerInstance $sqlInstance
}

Write-Host "Instalación de herramientas finalizada." -ForegroundColor Yellow