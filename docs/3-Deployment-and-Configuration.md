# Deployment and Configuration

The infrastructure deployment and database configuration are orchestrated through a single PowerShell script.

## Infrastructure Deployment

The main `Invoke-AzureDeployment.ps1` script is the entry point for provisioning all infrastructure in Azure.

**Usage:**

```powershell
# Deploy an Azure SQL Database environment
.\Invoke-AzureDeployment.ps1 -DeploymentType sql-db -EnvironmentName dev
```
```powershell
# Deploy an Azure SQL Managed Instance environment
.\Invoke-AzureDeployment.ps1 -DeploymentType sql-mi -EnvironmentName dev
```

**What does this script do?**

1. **Dynamic Parameter Generation**: Automatically detects the client's public IP to create a firewall rule and gets the Azure user's ID to grant them access to the Key Vault.

2. **Bicep Orchestration**: Executes the deployment of the corresponding Bicep template (`main-sql-db.bicep` or `main-sql-mi.bicep`).

3. **Polling Mechanism**: Actively waits for the Azure deployment to complete before proceeding to the next steps.

4. **Secure Secret Retrieval**: Once the infrastructure is created, it securely connects to the Key Vault to fetch the database credentials.

5. **Post-Deployment Configuration**: Calls the `Install-MaintenanceSolution.ps1` script to install and configure DBA tools on the newly created database.

## Standalone Utility Scripts

**Installing Maintenance Tools**

The `Scripts\Install-MaintenanceSolution.ps1` script is designed to be reusable and can be run independently to install a suite of DBA tools (defined in `config.json`) on any existing SQL Server instance.

```powershell
# Install the tools and create Ola Hallengren's maintenance jobs
.\Scripts\Install-MaintenanceSolution.ps1 -ServerInstance "your-server.database.windows.net" -CreateJobs
```

The `-CreateJobs` flag is optional and only applies to environments with a SQL Agent (like SQL Managed Instance or SQL Server on-prem/VM).