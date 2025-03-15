param codeId string
param location string = 'Canada Central'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-dev-calicot-cc-${codeId}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-dev-web-cc-${codeId}'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'snet-dev-db-cc-${codeId}'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

