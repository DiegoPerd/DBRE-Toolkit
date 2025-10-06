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

This flow is automatically triggered once you have completed local development.

1.  **Push your branch to GitHub:** `git push origin feature/my-new-index`.
2.  **Create a Pull Request (PR):** In GitHub, open a PR to merge your branch into `main`. This is the code review and approval step.
3.  **Merge the PR:** Once approved, merging into `main` automatically triggers the GitHub Actions workflow defined in `.github/workflows/build-and-deploy-dacpac.yml`.
4.  **The pipeline runs and performs the following actions:**
    * **Builds the `.dacpac`:** Compiles the database project from the source code.
    * **Logs into Azure:** Authenticates using a Service Principal configured in the repository's secrets.
    * **Deploys the `.dacpac`:** Publishes the changes to the target Azure database.
    * You can monitor the entire process from the "Actions" tab of your GitHub repository.