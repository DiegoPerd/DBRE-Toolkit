# Testing and Validation

The DBRE Toolkit includes a comprehensive suite of automated tests built with **Pester** to validate both the infrastructure and the database schema. The tests are located in the `/Tests` folder.

## Running the Test Suites

There are two main test suites, each with its own runner script.

### 1. Deployment Tests

These are integration tests that connect to Azure to verify that all expected infrastructure components have been deployed correctly.

**How to run:**

```powershell
.\Tests\Run-DeploymentTests.ps1
```

**What it does**:

The `Run-DeploymentTests.ps1` script dynamically fetches the names of the deployed Azure resources (Resource Group, SQL Server, Key Vault, etc.) and passes them as parameters to the `Deployment.Tests.ps1` test file. The test file then uses `az cli` commands to confirm the existence of each resource.

### 2. Database Tests

These tests connect to the deployed database to ensure that all expected database objects (procedures, tables, etc.) defined in `config.json` have been installed.

**How to run**:

```PowerShell
.\Tests\Run-DatabaseTests.ps1 
```

**What it does**:

The `Run-DatabaseTests.ps1` script fetches the necessary connection details, including securely retrieving credentials from Azure Key Vault. It then invokes the `Database.Tests.ps1` file, which:

Reads the `config.json` file to get a list of tools that should be installed.

Dynamically generates a Pester test case for each object.

Connects to the database and queries system views (like `sys.procedures` or `sys.tables`) to verify that each object exists.

This data-driven approach ensures that as you add new tools to `config.json`, the test suite automatically expands to validate them without needing to write new test code.