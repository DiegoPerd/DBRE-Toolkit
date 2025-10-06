# Infrastructure as Code (IaC) with Bicep

This project's infrastructure is fully managed using **Bicep**, a declarative language for deploying Azure resources. This ensures that environments are consistent, repeatable, and easy to manage.

## File Structure

The IaC logic resides in the `/IaC` folder and follows a modular pattern:

```text
IaC/
├── main-sql-db.bicep   # Orchestrator for Azure SQL Database
├── main-sql-mi.bicep   # Orchestrator for Azure SQL Managed Instance
└── modules/            # Reusable modules for each resource
    ├── dcr.module.bicep
    ├── keyvault.module.bicep
    ├── log-analytics.module.bicep
    ├── network.module.bicep
    ├── sql-db.module.bicep
    └── sql-mi.module.bicep
```

* `main-*.bicep` files: These act as orchestrators. They define which modules will be deployed and how they are interconnected. There is a `main` file for each deployment type (e.g., one for Azure SQL DB and another for SQL Managed Instance).

* `modules/` folder: Contains reusable Bicep templates for specific resources like `Key Vault`, `Log Analytics`, or the database itself. This promotes reuse and simplifies maintenance.

## Deployed Components
The IaC pipeline provisions the following resources in Azure:

**Azure SQL Database or Managed Instance**: The core database service.

**Azure Key Vault**: For secure secret management. Database credentials are automatically generated and stored here during deployment, eliminating the need to handle them manually.

**Log Analytics Workspace and Azure Monitor**: A Log Analytics workspace is deployed, and Data Collection Rules (DCRs) are configured to centralize database metrics and logs, laying the foundation for observability.