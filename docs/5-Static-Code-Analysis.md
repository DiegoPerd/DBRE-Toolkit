# 6. Static Code Analysis with SQLFluff

To ensure code quality, consistency, and adherence to best practices, this project has integrated **SQLFluff**, a powerful SQL linter, directly into the CI/CD pipeline. This acts as an automated quality gate, preventing code that violates established standards from being deployed.

## Why Static Code Analysis?

* **Enforces Consistency:** Ensures all SQL code follows the same style guide (e.g., keyword capitalization), making the codebase easier to read and maintain.
* **Catches Errors Early:** Identifies common mistakes and anti-patterns before they reach production.
* **Automates Code Reviews:** Frees up developers from having to manually check for style issues during pull request reviews.

## Implementation in this Project

The SQL linting process is configured through two key files and integrated into the GitHub Actions workflow.

### Configuration (`.sqlfluff`)

A `.sqlfluff` file in the root of the repository defines the linter's behavior. Our configuration uses an "opt-in" approach:

* **`dialect = tsql`**: Specifies that we are linting Transact-SQL code.
* **`rules = core, tsql.sp_prefix`**: We explicitly activate the `core` set of rules, plus specific dialect and convention rules that are disabled by default.
* **`exclude_rules`**: We disable specific layout and style rules from the `core` set to focus on more critical issues first.
* **Rule-specific configuration**: We configure active rules, such as forcing keywords to be uppercase.

### Ignoring Unparsable Files (`.sqlfluffignore`)

Some vendor-specific T-SQL syntax (like `CREATE XML SCHEMA COLLECTION`) is not fully supported by the parser. To prevent these files from causing parsing errors and failing the pipeline, a `.sqlfluffignore` file is used to instruct the linter to skip them entirely.

### CI/CD Integration

The linter is integrated as a prerequisite step in the `build-and-deploy-dacpac.yml` workflow.

```yaml
    - name: Install and run SQLFluff linter
      run: |
        pip install sqlfluff
        # Run the linter. If it finds any issues, this command will fail,
        # stopping the workflow before the build and deploy steps.
        sqlfluff lint src/AdventureWorks_Azs.database/
```

If `sqlfluff lint` finds any rule violations, it returns a non-zero exit code, which automatically causes the pipeline to fail. This prevents the code from being built or deployed, effectively enforcing the quality standard.

![SQLFluff TQ01 rule violation][def]

[def]: ./images/sqlfluff-failure.png