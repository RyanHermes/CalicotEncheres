param code string = '5'
param location string = 'Canada Central'
@secure()
param adminPassword string

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-dev-calicot-cc-${code}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'snet-dev-web-cc-${code}'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
            }
          ]
        }
      }
      {
        name: 'snet-dev-db-cc-${code}'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'plan-calicot-dev-${code}'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-calicot-dev-${code}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'ImageUrl'
          value: 'https://stcalicotprod000.${environment().suffixes.storage}/images/'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
      virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'snet-dev-web-cc-${code}')
    }
  }
}

// Autoscale settings
resource autoScale 'Microsoft.Insights/autoscalesettings@2015-04-01' = {
  name: 'autoscale-app-${code}'
  location: location
  properties: {
    enabled: true
    profiles: [
      {
        name: 'defaultProfile'
        capacity: {
          minimum: '1'
          maximum: '2'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 70
            }            
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
    targetResourceUri: appServicePlan.id
  }
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: 'sqlsrv-calicot-dev-${code}'
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
}

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: 'sqldb-calicot-dev-${code}'
  parent: sqlServer
  location: location
  properties: {
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}


// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: 'kv-calicot-dev-${code}'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

// Key Vault Access Policy
resource kvAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-11-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webApp.identity.principalId
        permissions: {
          secrets: ['get', 'list']
        }
      }
    ]
  }
}
