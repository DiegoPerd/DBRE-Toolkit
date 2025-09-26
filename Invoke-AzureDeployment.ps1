# deploy.ps1
# Main deployment script for the DBRE-Toolkit infrastructure.

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('sql-db', 'sql-mi')]
    [string]$DeploymentType, # Parameter for "WHAT" to deploy

    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName = 'dev' # Parameter for "WHERE" to deploy
)

# === Configuration ===
$resourceGroupName = "rg-dbre-lab" # Make the RG name dynamic
$baseIaCPath = ".\IaC\"

# === Logic ===

# Build the file names dynamically
$templateFileName = "main-$($DeploymentType).bicep"
$parametersFileName = "$($EnvironmentName)-$($DeploymentType).bicepparam"

$templateFile = Join-Path -Path $baseIaCPath -ChildPath $templateFileName
$parametersFile = Join-Path -Path $baseIaCPath -ChildPath $parametersFileName

Write-Host "Starting deployment..." -ForegroundColor Green
Write-Host "- Resource Group: $($resourceGroupName)"
Write-Host "- Deployment Type: $($DeploymentType)"
Write-Host "- Environment: $($EnvironmentName)"
Write-Host "- Template File: $($templateFile)"
Write-Host "- Parameters File: $($parametersFile)"

# Check if files exist before proceeding
if (-not (Test-Path $templateFile)) {
    throw "Template file not found: $templateFile"
}
if (-not (Test-Path $parametersFile)) {
    throw "Parameters file not found: $parametersFile. Please create it first."
}

# Construct and execute the deployment command
try {
    az deployment group create --resource-group $resourceGroupName --template-file $templateFile --parameters $parametersFile --no-wait | Out-Null
    Write-Host "Deployment command sent to Azure successfully." -ForegroundColor Green
}
catch {
    Write-Error "Deployment failed. Error: $($_.Exception.Message)"
}