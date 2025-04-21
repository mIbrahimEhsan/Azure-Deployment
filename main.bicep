@secure()
param adminPassword string
param location string = resourceGroup().location


param vnet1Name string = 'vnet1'
param vnet2Name string = 'vnet2'
param vnet1AddressPrefix string = '10.10.0.0/16'
param vnet1InfraSubnetPrefix string = '10.10.1.0/24'
param vnet1StorageSubnetPrefix string = '10.10.2.0/24'
param vnet2AddressPrefix string = '10.20.0.0/16'
param vnet2InfraSubnetPrefix string = '10.20.1.0/24'
param vnet2StorageSubnetPrefix string = '10.20.2.0/24'


// Deploying VNETs
module vnet1 './vnet.bicep' = {
  name: 'vnet1Deployment'  
  params: {
    vnetName: vnet1Name
    location: location
    vnetAddressPrefix: vnet1AddressPrefix
    infraSubnetPrefix: vnet1InfraSubnetPrefix
    storageSubnetPrefix: vnet1StorageSubnetPrefix
  }
}


module vnet2 './vnet.bicep' = {
  name: 'vnet2Deployment'
  params: {
    vnetName: vnet2Name
    location: location
    vnetAddressPrefix: vnet2AddressPrefix
    infraSubnetPrefix: vnet2InfraSubnetPrefix
    storageSubnetPrefix: vnet2StorageSubnetPrefix
  }
}

// Peering both of the vnets
module vnet1Tovnet2Peering './vnetpeer.bicep' = {
  name: 'vnet1-vnet2'
  params: {
    sourceVnetName: vnet1Name
    targetVnetId: vnet2.outputs.vnetId
    peeringName: 'peering-to-vnet2'
  }
  dependsOn: [
    vnet1
  ]
}


module vnet2Tovnet1Peering './vnetpeer.bicep' = {
  name: 'vnet2-vnet1'
  params: {
    sourceVnetName: vnet2Name
    targetVnetId: vnet1.outputs.vnetId
    peeringName: 'peering-to-vnet1'
  }
  dependsOn: [
    vnet2
  ]
}

module vm1 './vm.bicep' = {
  name: 'vm1Deployment'
  params: {
    vmName: 'vm1'
    location: location
    subnetId: vnet1.outputs.infraSubnetId
    adminPassword: adminPassword
  }
}

// Deploying Vms in both of the vnets
module vm2 './vm.bicep' = {
  name: 'vm2Deployment'
  params: {
    vmName: 'vm2'
    location: location
    subnetId: vnet2.outputs.infraSubnetId
    adminPassword: adminPassword
  }
}

// Adding storage account 
module storage1 './storage.bicep' = {
  name: 'storage1Deployment'
  params: {
    storageAccountName: 'st${uniqueString(resourceGroup().id)}1'
    location: location
  }
}

module storage2 './storage.bicep' = {
  name: 'storage2Deployment'
  params: {
    storageAccountName: 'st${uniqueString(resourceGroup().id)}2'
    location: location
  }
}

// Add after VM and storage modules
module monitor './monitor.bicep' = {
  name: 'monitorDeployment'
  params: {
    location: location
  }
}
