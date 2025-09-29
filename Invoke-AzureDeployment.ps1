# Invoke-AzureDeployment.ps1
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
$location = "NorthEurope"
$baseIaCPath = ".\IaC\"
$deploymentName = "dbre-toolkit-deployment-$(Get-Date -Format 'yyyyMMdd-HHmm')" # Unique name for the deployment

# Polling configuration
$maxRetries = 20 # 20 retries * 30 seconds = 10 minutes timeout for SQL DB
if ($DeploymentType -eq 'sql-mi') {
    $maxRetries = 120 # 120 retries * 3 minutes = 6 hours timeout for SQL MI
}
$retryIntervalSeconds = 30
if ($DeploymentType -eq 'sql-mi') {
    $retryIntervalSeconds = 180 # Check every 3 minutes for MI
}


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
    # === NEW: Discover Client Public IP ===
    Write-Host "Discovering client public IP address..."
    $clientIpAddress = (Invoke-RestMethod -Uri 'https://api.ipify.org').Trim()
    if (-not $clientIpAddress) {
        throw "Could not determine client IP address."
    }
    Write-Host "Client IP found: $clientIpAddress" -ForegroundColor Cyan
    
    az group create --name $resourceGroupName --location $location | Out-Null
    az deployment group create --name $deploymentName --resource-group $resourceGroupName --template-file $templateFile --parameters $parametersFile --parameters clientIpAddress=$clientIpAddress | Out-Null
    Write-Host "Deployment command sent to Azure successfully." -ForegroundColor Green

     # --- CONFIGURATION PHASE ---
    Write-Host "Starting post-deployment configuration..." -ForegroundColor Yellow
    # --- Read parameters from the .bicepparam file ---
    Write-Host "Reading credentials from parameters file..."
    $paramFileContent = Get-Content -Path $parametersFile -Raw
    # Use regex to find the admin login and password
    $sqlAdminLogin = $paramFileContent | Select-String -Pattern "param sqlAdminLogin = '(.*)'" | ForEach-Object { $_.Matches.Groups[1].Value }
    $sqlAdminPassword = $paramFileContent | Select-String -Pattern "param sqlAdminPassword = '(.*)'" | ForEach-Object { $_.Matches.Groups[1].Value }

    if ([string]::IsNullOrEmpty($sqlAdminLogin) -or [string]::IsNullOrEmpty($sqlAdminPassword)) {
        throw "Could not parse sqlAdminLogin or sqlAdminPassword from '$($parametersFile)'. Please check the file."
    }   


    # Create a secure PSCredential object
    $securePassword = ConvertTo-SecureString -String $sqlAdminPassword -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($sqlAdminLogin, $securePassword)
    Write-Host "Credentials created securely for user '$($sqlAdminLogin)'."

     # --- POLLING PHASE ---
    for ($i = 1; $i -le $maxRetries; $i++) {
        $deploymentState = az deployment group show --name $deploymentName --resource-group $resourceGroupName --query "properties.provisioningState" --output tsv
        Write-Host "Attempt $i/${maxRetries}: Deployment state is '$($deploymentState)'..."

        if ($deploymentState -eq 'Succeeded') {
            Write-Host "Provisioning completed successfully!" -ForegroundColor Green
            break # Exit the loop
        }
        if ($deploymentState -eq 'Failed' -or $deploymentState -eq 'Canceled') {
            throw "Infrastructure provisioning failed with state: $($deploymentState). Please check the Azure Portal for details."
        }
        if ($i -eq $maxRetries) {
            throw "Timeout reached. Provisioning is taking too long. Please check the Azure Portal."
        }
        
        Start-Sleep -Seconds $retryIntervalSeconds
    }


    # Get the server name from the deployment outputs
    $sqlServerName = az deployment group show --name $deploymentName --resource-group $resourceGroupName --query "properties.outputs.sqlServerName.value" --output tsv
    if ([string]::IsNullOrEmpty($sqlServerName)) {
        throw "Could not retrieve SQL Server name from deployment outputs."
    }
    
    # Determine if Agent Jobs should be created based on deployment type
    $createJobs = ($DeploymentType -eq 'sql-mi')

    Write-Host "Running installation script against '$($sqlServerName)'..."
    
    # Call the installation script, passing the server name and job flag as parameters
    $fullyQualifiedServerName = "$($sqlServerName).database.windows.net"
    .\Scripts\Install-MaintenanceSolution.ps1 -ServerInstance $fullyQualifiedServerName -CreateJobs $createJobs -Credential $credential
    
    Write-Host "Configuration finished successfully." -ForegroundColor Green
}
catch {
    Write-Error "Deployment failed. Error: $($_.Exception.Message)"
}