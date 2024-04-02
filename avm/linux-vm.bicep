targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

param vmName string
param vmSize string

param vmSubnetResourceId string
param vmAdminUsername string

@secure()
param vmAdminPassword string

 @secure()
param vmSshPublicKey string = ''

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param vmAuthenticationType string = 'password'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

param location string = resourceGroup().location



// ------------------
// VARIABLES
// ------------------

var resourceNames = {
  nicName: '${vmName}-nic'
}

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${vmAdminUsername}/.ssh/authorized_keys'
        keyData: vmSshPublicKey
      }
    ]
  }
}

// ------------------
// RESOURCES
// ------------------


resource vmNetworkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: resourceNames.nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vmSubnetResourceId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
      linuxConfiguration: ((vmAuthenticationType == 'password') ? null : linuxConfiguration)
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNetworkInterface.id
        }
      ]
    }
  }
}
