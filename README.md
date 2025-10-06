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
* **CI/CD Foundation:** A `.github/workflows/build-and-deploy-dacpac.yml` file defines a Continuous Integration pipeline that automatically builds the database project into a `.dacpac` artifact upon changes to the source code.
* **Secure Secret Management:** Implements **Azure Key Vault** to store and retrieve database credentials securely during the deployment and configuration phases, avoiding plain-text secrets.

## 🚀 Getting Started

To learn more about the project's architecture, how to deploy it, and the development workflows, please refer to the detailed documentation:

* **[Docs Folder](./docs/1-Introduction.md)**
