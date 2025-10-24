# Development and CI/CD Workflows

The project is designed to support two primary workflows: a rapid local development cycle and a fully automated CI/CD pipeline for Azure deployments.

## Local Development Workflow (Inner Loop)

This is the workflow for making and testing changes on your local machine before integration.

1.  **Create a new branch:** `git checkout -b feature/my-new-index`.
2.  **Modify the database code:** Make the necessary changes to the `.sql` files within the `src/` folder.
3.  **Generate a deployment report:** From VS Code, run the task `Tasks: Run Task -> Generate Deploy Report`. This creates a `deployment_script.sql` file for you to review the changes that will be applied.
4.  **Deploy to your local instance:** Use the `Deploy Local (Safe)` task (which prevents data loss) or `Deploy Local (Force)` to apply the changes to your local database.
5.  **Test the changes:** Connect to your local database with SSMS or your preferred tool and verify that the changes work as expected.
6.  **Commit your changes:** Once satisfied, commit your work: `git commit -m "feat: Add new index to improve performance"`.

## CI/CD Workflow (Outer Loop)

### Option A: CI/CD with GitHub Actions

Workflows are defined in the `.github/workflows/` directory.

#### Pull Request Validation (`pr-validation.yml`)

This workflow acts as a **quality gate** for any code changes proposed to the `main` branch.

1.  **Trigger:** Automatically runs when a Pull Request is opened or updated targeting `main`, but only if changes are detected within the `src/AdventureWorks_Azs.database/` path. It can also be triggered manually (`workflow_dispatch`).
2.  **Actions:**
    * Checks out the code from the Pull Request branch.
    * Runs the **SQLFluff linter**.
    * **Builds** the `.dacpac` artifact.
    * Uses a **matrix strategy** to deploy the `.dacpac` to **DEV** and **QA** environments in parallel, leveraging GitHub Environments for secrets (`AZURE_CREDENTIALS`, `AZURE_SQL_CONNECTION_STRING`).
    * Runs simulated automated tests against DEV and QA.
3.  **Outcome:** Pipeline failure prevents merging if linting, build, deployment, or tests fail.

#### Production Deployment (`production-deploy.yml`)

Handles the deployment to the production environment.

1.  **Trigger:** Automatically runs only when code is merged (pushed) into `main`, and only if changes are detected within the `src/AdventureWorks_Azs.database/` path.
2.  **Actions:**
    * Checks out the code from `main`.
    * **Builds** the `.dacpac`.
    * **Deploys** the `.dacpac` to **Production** using the Production GitHub Environment secrets.
    * Runs post-deployment validation simulations.
3.  **Outcome:** Ensures validated code from `main` reaches production safely.

---

### Option B: CI/CD with Azure DevOps Pipelines

Pipelines are defined in the `.azure-pipelines/` directory.

#### Pull Request Validation (`pr-validation.yml`)

Acts as the **quality gate** for Pull Requests targeting `main`.

1.  **Trigger:** Automatically runs when a Pull Request is opened or updated targeting `main`, but only if changes are detected within the `src/AdventureWorks_Azs.database/` path (requires trigger override to be disabled in ADO UI).
2.  **Actions:**
    * Checks out the code.
    * Runs the **SQLFluff linter**.
    * **Builds** the `.dacpac`.
    * Uses a **template (`deploy-steps.yml`)** and a **compile-time loop (`${{ each }}`)** to deploy the `.dacpac` sequentially or in parallel to **DEV** and **QA**. It uses Azure DevOps Service Connections and Variable Groups linked to Azure Key Vault for environment-specific configuration (`AZURE_SQL_CONNECTION_STRING`).
    * Runs simulated automated tests against DEV and QA.
3.  **Outcome:** Pipeline failure prevents PR completion if any step fails.

#### Production Deployment (`production-deploy.yml`)

Handles deployment to the production environment.

1.  **Trigger:** Automatically runs only when code is merged (pushed) into `main`, and only if changes are detected within the `src/AdventureWorks_Azs.database/` path (requires trigger override to be disabled in ADO UI).
2.  **Actions:**
    * Checks out the code from `main`.
    * **Builds** the `.dacpac`.
    * **Deploys** the `.dacpac` to **Production** using its dedicated Service Connection and Variable Group.
    * Runs post-deployment validation simulations.
3.  **Outcome:** Ensures validated code reaches production safely.

