targetScope = 'subscription'

// ------------------
// PARAMETERS
// ------------------

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(20)
param workloadName string = 'min999-proj99'


@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = deployment().location

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environment string = 'dev'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The address prefix for the virtual network.')
param addressPrefix string = '10.0.0.0/16'

param vmSettings object 


// ------------------
// VARIABLES
// ------------------
var resourceNames = {
  rgName: '${workloadName}-${environment}-rg'
  vnetName: '${workloadName}-${environment}-vnet'
  vmName: '${workloadName}-${environment}-vm'
}


// ------------------
// RESOURCES
// ------------------

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceNames.rgName
  location: location
  tags: tags
}

module vnet 'deploy.network.bicep' = {
  scope: resourceGroup
  name: take('vnet-module-${deployment().name}', 64)
  params: {
    location: location
    tags: tags
    name: resourceNames.vnetName
    addressPrefix: addressPrefix
  }
}

@description('An optional Linux virtual machine deployment to act as a jump box.')
module jumpboxLinuxVM '../avm/linux-vm.bicep' = {
  name: take('vm-linux-${deployment().name}', 64)
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    vmName: resourceNames.vmName
    vmAdminUsername: vmSettings.vmAdminUsername
    vmAdminPassword: vmSettings.vmAdminPassword
    vmSize: vmSettings.vmSize
    vmSubnetResourceId: vnet.outputs.snetPeResourceId
  }
}

// ------------------
// OUTPUTS
// ------------------
