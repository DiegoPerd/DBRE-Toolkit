# 7. Monitoring and Observability as Code

A core principle of DBRE is treating every component of the database ecosystem as code, and this includes our monitoring and alerting strategy. This project implements "Monitoring as Code" by defining alert rules declaratively using Bicep.

## Alerting as Code

Instead of manually creating alerts in the Azure Portal, we define them in a reusable Bicep module (`/IaC/modules/monitoring.module.bicep`). This ensures that our alerting strategy is version-controlled, repeatable, and consistent across all environments.

For this project, we have defined a key alert:

* **High CPU Utilization:** An alert is automatically configured to trigger if the database's CPU usage remains above 80% for a continuous 5-minute period. This alert is defined in code and deployed alongside the database itself.

This approach demonstrates how a DBRE can build a reliable and automated monitoring foundation from the ground up.

### Example: High CPU Alert in Bicep

```bicep
// From /IaC/modules/monitoring.module.bicep
resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'sql-high-cpu-alert'
  location: 'global'
  properties: {
    description: 'Alert when CPU usage is over 80% for 5 minutes.'
    severity: 1
    enabled: true
    scopes: [
      targetResourceId
    ],
    criteria: {
      // ... criteria definition ...
    }
  }
}