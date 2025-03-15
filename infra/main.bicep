iresource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-calicot-dev'
  location: 'Canada Central'
}
resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: 'vnet-dev-calicot'
  location: rg.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-dev-web'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'snet-dev-db'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-calicot-dev'
  location: rg.location
  properties: {
    sku: {
      name: 'S1'
      tier: 'Standard'
    }
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'app-calicot-dev'
  location: rg.location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'ImageUrl'
          value: 'https://stcalicotprod000.blob.core.windows.net/images/'
        }
      ]
    }
    httpsOnly: true
    alwaysOn: true
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-02-01' = {
  name: 'sqlsrv-calicot-dev'
  location: rg.location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'yourSecurePassword123'
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/databases@2021-02-01' = {
  name: 'sqldb-calicot-dev'
  location: rg.location
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01' = {
  name: 'kv-calicot-dev'
  location: rg.location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01' = {
  name: 'ConnectionStrings'
  parent: keyVault
  properties: {
    value: 'your-connection-string-here'
  }
}

