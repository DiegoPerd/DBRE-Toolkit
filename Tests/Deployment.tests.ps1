# Tests/Deployment.Tests.ps1
# Contains integration tests to validate that Azure resources were deployed correctly.

param(
    [string]$ExpectedResourceGroupName,
    [string]$ExpectedSqlServerName,
    [string]$ExpectedDbName,
    [string]$ExpectedKeyVaultName,
    [string]$ExpectedLogAnalyticsName,
    [string]$ExpectedDcrName    
)

Describe "Azure Infrastructure Post-Deployment Validation" {

    It "Should have deployed the Resource Group"{
        Write-Host "Verifying existence of Resource Group: $ExpectedResourceGroupName"
        $resourceGroup = az group show --name $ExpectedResourceGroupName --output json | ConvertFrom-Json
        $resourceGroup | Should -Not -BeNull
        $resourceGroup.name | Should -Be $ExpectedResourceGroupName

    }
     It "Should have deployed the SQL Server" {
        Write-Host "Verifying existence of SQL Server: $ExpectedSqlServerName..."
        $sqlServer = az sql server show --name $ExpectedSqlServerName --resource-group $ExpectedResourceGroupName --output json | ConvertFrom-Json
        $sqlServer | Should -Not -BeNull
        $sqlServer.name | Should -Be $ExpectedSqlServerName
    }

    It "Should have deployed the SQL Database" {
        Write-Host "Verifying existence of SQL Database: $ExpectedDbName..."
        $sqlDatabase = az sql db show --name $ExpectedDbName --resource-group $ExpectedResourceGroupName --server $ExpectedSqlServerName --output json | ConvertFrom-Json
        $sqlDatabase | Should -Not -BeNull
        $sqlDatabase.name | Should -Be $ExpectedDbName
    }

    It "Should have deployed the Key Vault" {
        Write-Host "Verifying existence of Key Vault: $ExpectedKeyVaultName..."
        $keyVault = az keyvault show --name $ExpectedKeyVaultName --resource-group $ExpectedResourceGroupName --output json | ConvertFrom-Json
        $keyVault | Should -Not -BeNull
        $keyVault.name | Should -Be $ExpectedKeyVaultName
    }

    It "Should have deployed the Log Analytics Workspace" {
        Write-Host "Verifying existence of Log Analytics Workspace: $ExpectedLogAnalyticsName..."
        $logAnalytics = az monitor log-analytics workspace show --name $ExpectedLogAnalyticsName --resource-group $ExpectedResourceGroupName --output json | ConvertFrom-Json
        $logAnalytics | Should -Not -BeNull
        $logAnalytics.name | Should -Be $ExpectedLogAnalyticsName
    }

    It "Should have deployed the Data Collection Rule (DCR)" {
        Write-Host "Verifying existence of Data Collection Rule: $ExpectedDcrName..."
        $dcr = az monitor data-collection rule show --name $ExpectedDcrName --resource-group $ExpectedResourceGroupName --output json | ConvertFrom-Json
        $dcr | Should -Not -BeNull
        $dcr.name | Should -Be $ExpectedDcrName
    }

}