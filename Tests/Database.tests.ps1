# Tests/Database.Tests.ps1
# Dynamically generates tests based on the project's config file.

# === Configuration ===
param(
    [string]$ServerInstance,
    [string]$DatabaseName,
    [string]$KeyVaultName
)

# Find and load the config file
$configFile = "$PSScriptRoot/../config.json"
if (-not (Test-Path $configFile)) {
    throw "Configuration file not found at '$configFile'"
}
$config = Get-Content -Path $configFile -Raw | ConvertFrom-Json

# === Test Suite ===
# We create an array where each item has a calculated 'ProcedureName' property.
$testCases = foreach ($tool in $config.toolsToInstall) {
    [pscustomobject]@{
        ObjectName = (Split-Path -Path $tool.url -Leaf).Replace('.sql', '')
        ObjectType = $tool.objectType
    }
}

# Securely retrieve the SQL password from Azure Key Vault
Write-Host "Retrieving SQL password from Key Vault '$($KeyVaultName)'..."
$sqlAdminPassword = az keyvault secret show --vault-name $KeyVaultName --name "sqlAdminPassword" --query "value" --output tsv

# Securely retrieve the SQL admin username from Azure Key Vault
Write-Host "Retrieving SQL admin username from Key Vault '$($KeyVaultName)'..."
$sqlAdminLogin = az keyvault secret show --vault-name $KeyVaultName --name "sqlAdminLogin" --query "value" --output tsv

# Create the PSCredential object
$securePassword = ConvertTo-SecureString -String $sqlAdminPassword -AsPlainText -Force
Describe "Database Object Validation (from config.json)" -ForEach $testCases {

    BeforeAll{      
        $script:credential = New-Object System.Management.Automation.PSCredential($sqlAdminLogin, $securePassword)
    }
    
    # Dynamically create a test case for each procedure
    It "Should have installed '$($_.procedureName)'" {
        
        $currentObjectName = $_.ObjectName
        $currentObjectType = $_.ObjectType

        Write-Host "Verifying existence of $($currentObjectName)..."
        $query = ""
        switch ($currentObjectType) {
            'P' { $query = "SELECT 1 FROM sys.procedures WHERE name = '$($currentObjectName)'" }
            'T' { $query = "SELECT 1 FROM sys.tables WHERE name = '$($currentObjectName)'" }            
            'F' { $query = "SELECT 1 FROM sys.objects WHERE type IN (N'FN', N'IF', N'TF') and name = '$($currentObjectName)'" }            
            'V' { $query = "SELECT 1 FROM sys.views WHERE name = '$($currentObjectName)'" }
            'J' { $query = "SELECT 1 FROM msdb.dbo.sysjobs WHERE name = '$($currentObjectName)'" }
            default { throw "Unsupported object type '($currentObjectType)' in config." }
        }
        $result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -Credential $credential -ErrorAction SilentlyContinue            
        $result | Should -Not -BeNull
    
    }
}