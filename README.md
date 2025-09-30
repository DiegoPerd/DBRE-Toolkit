# DBRE Toolkit

This project is a demonstration of modern Database Reliability Engineering (DBRE) practices, showcasing how to manage a database's entire lifecycle—from infrastructure provisioning to software configuration and testing—using code and automation.

## 🚀 Features

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

## 🚀 How to Use

### 1. Deploy Infrastructure
Deploys the Azure infrastructure defined in the `/IaC` folder.

#### Deploy an Azure SQL Database environment
```powershell
.\Invoke-AzureDeployment.ps1 -DeploymentType sql-db -EnvironmentName dev
```
#### Deploy an Azure SQL Managed Instance environment
```powershell
.\Invoke-AzureDeployment.ps1 -DeploymentType sql-mi -EnvironmentName dev
```
### 2. Run Tests

#### Run Database Tests
```powershell
.\Tests\Run-DatabaseTests.ps1 
```
#### Run Database Tests
```powershell
.\Tests\Run-DeploymentTests.ps1 
```
## 🛠️ Technologies Used

* PowerShell 7
* Bicep
* Azure CLI
* Git & GitHub
* Azure DevOps (Pipelines)
* Pester
* Azure SQL, Azure Key Vault, Azure Monitor