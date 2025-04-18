@description('Virtual machine name')
param vmName string

@description('Virtual machine size')
param vmSize string = 'Standard_B1s' // Smallest size for cost savings

@description('Admin username')
param adminUsername string = 'ibrahim'

@description('Admin password')
@secure()
param adminPassword string

@description('Location for resources')
param location string = resourceGroup().location

@description('Subnet ID where the VM will be placed')
param subnetId string

// Create public IP for VM access
resource publicIP 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: '${vmName}-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Create network interface
resource nic 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

// Create VM
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output vmId string = vm.id
output vmName string = vm.name
