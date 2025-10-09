// IaC/modules/action-group.module.bicep
// Defines an Action Group to notify via email.

@description('The name of the action group.')
param actionGroupName string

@description('The email address to receive notifications.')
param emailReceiver string

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: actionGroupName
    enabled: true
    emailReceivers: [
      {
        name: 'dbre-admin-email'
        emailAddress: emailReceiver
        useCommonAlertSchema: true
      }
    ]
  }
}

// Output the name for other modules to use
output name string = actionGroup.name
