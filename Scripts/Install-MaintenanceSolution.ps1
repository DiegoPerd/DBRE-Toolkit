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
   
    Write-Host "Downloading '$fileName' to '$destinationPath'..."
    
    # Download the file to $env:temp
    try {
        Invoke-WebRequest -Uri $Url -OutFile $destinationPath -UseBasicParsing
        Write-Host "Download completed successfully to: $destinationPath" -ForegroundColor Green
        # Install on the instance
        try {                
            Invoke-Sqlcmd -InputFile $destinationPath -ServerInstance $ServerInstance -TrustServerCertificate  -Credential $Credential -ErrorAction Stop
            Write-Host "$filename installed successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to install the file $filename. Error: $($_.Exception.Message)"
        }
    }
    catch {
        Write-Error "Failed to download the file $filename. Error: $($_.Exception.Message)"                       
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

    Write-Host "Creating Ola Hallengren's SQL Agent jobs..." -ForegroundColor Yellow

    # --- 1. Create the Index Optimization job ---
    $indexParams = $Configuration.olaHallengrenJobConfig.IndexOptimize
    $templatePath = Join-Path -Path $PSScriptRoot -ChildPath "Templates\Create-Ola-Jobs.sql"

    # Read the SQL template
    $sqlTemplate = Get-Content -Path $templatePath -Raw

    # Replace the placeholders
    $finalSql = $sqlTemplate `
        -replace '__FragmentationLow__', $indexParams.FragmentationLow `
        -replace '__FragmentationMedium__', $indexParams.FragmentationMedium `
        -replace '__FragmentationHigh__', $indexParams.FragmentationHigh `
        -replace '__FragmentationLevel1__', $indexParams.FragmentationLevel1 `
        -replace '__FragmentationLevel2__', $indexParams.FragmentationLevel2 `
        -replace '__LogToTable__', $indexParams.LogToTable

    # Execute the final SQL
    try {
        Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $finalSql -TrustServerCertificate -Credential $Credential  -ErrorAction Stop
        Write-Host "Jobs created and configured successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create the jobs. Error: $($_.Exception.Message)"
    }

}


# --- Configuration ---
$projectRoot = Split-Path -Path $PSScriptRoot -Parent
$configPath = Join-Path -Path $projectRoot -ChildPath "config.json"
Write-Host "Loading configuration from: $configPath"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$sqlInstance = $ServerInstance

Write-Host "Starting tool installation on instance '$sqlInstance'..." -ForegroundColor Yellow

foreach ($tool in $config.toolsToInstall) {
    Write-Host "Processing $($tool.name)..."
    Install-SqlScriptFromUrl -Url $tool.url -ServerInstance $sqlInstance -Credential $Credential
}

if ($CreateJobs){
    Install-OlaHallengrenJobs -ServerInstance $sqlInstance -Configuration $config -Credential $Credential
}



Write-Host "Tool installation finished." -ForegroundColor Yellow