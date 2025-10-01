# DBRE Toolkit

This project is a demonstration of modern Database Reliability Engineering (DBRE) practices, showcasing how to manage a database's entire lifecycle—from infrastructure provisioning to software configuration and testing—using code and automation.

## ✨ Features

This toolkit is built around a set of modular and automated components:

* **Infrastructure as Code (IaC):** The entire Azure infrastructure is defined declaratively using **Bicep**. The project is structured with a multi-stage `main` orchestrator and reusable `modules` for each component, including SQL Database, SQL Managed Instance, Key Vault, and monitoring.
* **Automated Deployment Orchestration:** A central PowerShell script (`Invoke-AzureDeployment.ps1`) acts as the main entry point, handling dynamic parameter generation (like client IP and user principal ID), and providing a robust polling mechanism to wait for asynchronous deployments to complete.
* **Database Schema as Code:** The database schema is managed in a **SQL Server Database Project** (`.sqlproj`), allowing the entire database structure to be version-controlled in Git.
* **Configuration as Code:** A central `config.json` file acts as a manifest to drive the post-deployment configuration, such as installing community DBA tools.
* **Comprehensive Automated Testing:** The project includes a `Tests` folder with a suite of **Pester** tests:
    * **Integration Tests** that connect to Azure to validate that infrastructure has been deployed correctly (`Deployment.Tests.ps1`).
    * **Data-Driven Tests** that read the `config.json` to dynamically verify that all expected database objects have been installed (`Database.Tests.ps1`).
* **CI/CD Foundation:** An `azure-pipelines.yml` file defines a Continuous Integration pipeline that automatically builds the database project into a `.dacpac` artifact upon changes to the source code.
* **Secure Secret Management:** Implements **Azure Key Vault** to store and retrieve database credentials securely during the deployment and configuration phases, avoiding plain-text secrets.

## 📁 Project Structure

```text
.
├── .github             # Contains the GitHub Actions CI/CD workflow definition.
├── .vscode             # Contains the VsCode Actions local workflow definition.
├── IaC/                # Bicep templates for Infrastructure as Code
│   ├── main-*.bicep    # Entry points for different deployments
│   └── modules/        # Reusable Bicep modules
├── Scripts/            # PowerShell scripts for post-deployment configuration
├── src/                # Source code for the database project (.sqlproj)
├── Tests/              # Pester tests (Integration and Database)
├── .gitignore
├── azure-pipelines.yml # CI pipeline definition
├── config.json         # Manifest for tool installation
├── Invoke-AzureDeployment.ps1 # Main orchestration script
└── README.md
```
## 🚀 Getting Started

Follow these steps to deploy the infrastructure and get the project running.

### Prerequisites

Ensure you have the following tools installed and configured:
* Git
* Azure CLI (logged in with `az login`)
* PowerShell 7+
* .NET 8 SDK
* SqlPackage.exe (install via `dotnet tool install --global Microsoft.SqlPackage`)
* A local SQL Server instance for development.

## 🗺️ How to Use

### 1. Deploy Infrastructure
Deploys the Azure infrastructure defined in the `/IaC` folder.

#### Deploy an Azure SQL Database environment
```powershell
.\Invoke-AzureDeployment.ps1 -DeploymentType sql-db -EnvironmentName dev
```
Or
#### Deploy an Azure SQL Managed Instance environment
```powershell
.\Invoke-AzureDeployment.ps1 -DeploymentType sql-mi -EnvironmentName dev
```

### 2. Workflows

This project is designed around two primary workflows.

## Local Development Workflow
This is the rapid "inner-loop" cycle for making and testing changes on your local machine.

1. Create a new branch for your feature (`git checkout -b feature/my-new-index`).
2. Modify the database code in the `.sql` files within VS Code.
3. Generate a deployment report to preview the changes (`Ctrl+Shift+P -> Tasks: Run Task -> Generate Deploy Report`). This creates a `deployment_script.sql` file for you to review.
4. Deploy to your local SQL instance using the appropriate task: `Deploy Local (Safe)` or `Deploy Local (Force)`.
5. Test your changes against your local database using SSMS or your preferred tool.
6. Once satisfied, commit your changes (`git commit -m "feat: Add new index for performance"`).

## CI/CD Workflow (Deploying to Azure)
This "outer-loop" workflow is fully automated and triggers once your local development is complete.

1. Push your branch to GitHub (`git push origin feature/my-new-index`).
2. Create a Pull Request (PR) in GitHub to merge your branch into `main`. This is the code review and approval step.
3. Merge the PR. Upon merging, the GitHub Actions pipeline is automatically triggered.
4. The pipeline will:
* Build the `.dacpac` from the source code.
* Log in to Azure using the configured Service Principal.
* Deploy the `.dacpac` to the target Azure SQL Database.
* You can monitor the entire process in the "Actions" tab of the repository.

### 3. Run Tests

#### Run Database Tests
```powershell
.\Tests\Run-DatabaseTests.ps1 
```
#### Run Deployment Tests
```powershell
.\Tests\Run-DeploymentTests.ps1 
```

## 🛠️ Standalone Utility Scripts

Beyond the main deployment orchestrator, this repository contains scripts that can be run independently for specific configuration tasks.

### Installing DBA Maintenance Tools

The `Install-MaintenanceSolution.ps1` script can be used to install a suite of popular community DBA tools (defined in `config.json`) onto any existing SQL Server instance. This is useful for configuring servers that were not provisioned by this project's IaC workflow.

**Usage:**

The script requires the target server name and will prompt for credentials securely.

```powershell
# Run the script against a target SQL Server instance
.\Scripts\Install-MaintenanceSolution.ps1 -ServerInstance "your-server-name.database.windows.net" -CreateJobs
```

The -CreateJobs flag will create and configure the standard Ola Hallengren maintenance jobs. This is only applicable to SQL Server environments that have a SQL Agent.


## 🛠️ Technologies Used

* PowerShell 7
* Bicep
* Azure CLI
* Visual Studio Code
* Git & GitHub
* Azure DevOps (Pipelines)
* Pester
* Azure SQL, Azure Key Vault, Azure Monitor