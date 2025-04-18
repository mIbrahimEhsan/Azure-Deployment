@description('Storage account name')
param storageAccountName string

@description('Location for resources')
param location string

// Simplified storage account without network rules for now
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'  // Using LRS instead of ZRS as ZRS might not be available in this region
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

output storageId string = storageAccount.id
output storageName string = storageAccount.name
