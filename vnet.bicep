// Parameters define values that can be passed when deploying
@description('Virtual network name')
param vnetName string  // This parameter is required and has no default

@description('Location for all resources')
param location string = resourceGroup().location  // Default uses the resource group's location

@description('Address prefix for the VNet')
param vnetAddressPrefix string

@description('Infra subnet address prefix')
param infraSubnetPrefix string

@description('Storage subnet address prefix')
param storageSubnetPrefix string

// This creates the actual VNET resource
resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix  // The CIDR range for the whole VNET
      ]
    }
    subnets: [
      {
        name: 'infra'  // First subnet for infrastructure/VMs
        properties: {
          addressPrefix: infraSubnetPrefix
        }
      }
      {
        name: 'storage'  // Second subnet for storage accounts
        properties: {
          addressPrefix: storageSubnetPrefix
        }
      }
    ]
  }
}

// Outputs make values available to other modules that reference this module
output vnetId string = vnet.id  // Full resource ID of the VNET
output infraSubnetId string = '${vnet.id}/subnets/infra'  // ID of the infra subnet
output storageSubnetId string = '${vnet.id}/subnets/storage'  // ID of the storage subnet
