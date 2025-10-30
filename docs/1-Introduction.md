# Introduction to the DBRE Toolkit

Welcome to the DBRE Toolkit documentation.

This project is a hands-on demonstration of **Database Reliability Engineering (DBRE)** principles. Its goal is to showcase how to manage the entire lifecycle of a database as if it were software: infrastructure provisioning, change deployment, configuration, and testing, all managed as code and automated.

## Core Principles

The toolkit is built on the following pillars:

* **Infrastructure as Code (IaC):** The entire Azure infrastructure is defined declaratively using **Bicep**, making it versionable, repeatable, and auditable.
* **Everything as Code:** Not just the infrastructure, but also the database schema, tool configurations, and CI/CD pipelines are defined in files within this repository.
* **Automation:** Manual processes are eliminated in favor of automated scripts and pipelines to reduce errors and increase delivery speed.
* **Observability and Testing:** The system is designed to be observable from the start, with centralized metrics and logs. Automated tests ensure that both the infrastructure and the database function as expected.

Browse the sections of this documentation to understand each component of the project in detail.

## 📁 Project Structure

```text
├── .azure-pipelines/   # Contains the Azure Devops pipelines definition.
├── .github/            # Contains the GitHub Actions CI/CD workflow definition.
├── .vscode/            # Contains the VsCode Actions local workflow definition.
├── docs/               # Contains the documentation md files.
├── IaC/                # Bicep templates for Infrastructure as Code
│   ├── main-*.bicep    # Entry points for different deployments
│   └── modules/        # Reusable Bicep modules
├── Scripts/            # PowerShell scripts for post-deployment configuration
├── src/                # Source code for the database project (.sqlproj)
├── Tests/              # Pester tests (Integration and Database)
├── config.json         # Manifest for tool installation
├── Invoke-AzureDeployment.ps1 # Main orchestration script
└── README.md
```

### Prerequisites

Ensure you have the following tools installed and configured:
* Git
* Azure CLI (logged in with `az login`)
* PowerShell 7+
* .NET 8 SDK
* SqlPackage.exe (install via `dotnet tool install --global Microsoft.SqlPackage`)
* A local SQL Server instance for development.