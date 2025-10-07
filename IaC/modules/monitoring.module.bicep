// IaC/modules/monitoring.module.bicep
// Defines metric alerts for the SQL Database.

@description('Name of the alert rule.')
param alertRuleName string

@description('The resource ID of the SQL Database to monitor.')
param targetResourceId string

@description('The name of the action group to trigger.')
param actionGroupName string

// Get the Action Group Resource ID from the subscription
var actionGroupId = resourceId('Microsoft.Insights/actionGroups', actionGroupName)

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertRuleName
  // Metric alerts must be in this 'global' location
  location: 'global'
  properties: {
    description: 'Alert when CPU usage is over 80% for 5 minutes.'
    severity: 1 // 1 = Warning
    enabled: true
    scopes: [
      targetResourceId
    ]
    evaluationFrequency: 'PT1M' // Evaluate every minute
    windowSize: 'PT5M' // Over a 5-minute window
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'HighCPU'
          metricName: 'cpu_percent'
          metricNamespace: 'Microsoft.Sql/servers/databases'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}
