# Tests/Run-DeploymentTests.ps1
# This script retrieves Azure resource details and runs the Pester test suite.


Write-Host "Fetching Azure resource names..."

$resourceGroup = az group list --query "[0].name" -o tsv
$serverName = az sql server list --resource-group $resourceGroup --query "[0].name" -o tsv
$dbName = az sql db list --resource-group $resourceGroup --server $serverName --query "[0].name" -o tsv
$keyVaultName = az keyvault list --resource-group $resourceGroup --query "[0].name" -o tsv
$logAnalytics= az monitor log-analytics workspace list --resource-group $resourceGroup --query "[0].name" -o tsv
$dcrName = az monitor data-collection rule list --resource-group $resourceGroup --query "[0].name" -o tsv


# === Pester 5 Configuration ===
# Step 1: Create a hashtable with the data for the test script's parameters.
$testData = @{
    ExpectedResourceGroupName  = $resourceGroup
    ExpectedSqlServerName = $serverName
    ExpectedDbName = $dbName
    ExpectedKeyVaultName = $keyVaultName
    ExpectedLogAnalyticsName = $logAnalytics
    ExpecteddcrName = $dcrName    
}

# Step 2: Create a Pester "Container" that bundles the test file and its data.
$container = New-PesterContainer -Path '.\Deployment.Tests.ps1' -Data $testData

Write-Host "Executing Deployment test suite..."

# Step 3: Call Invoke-Pester with the -Container parameter.
Invoke-Pester -Container $container
