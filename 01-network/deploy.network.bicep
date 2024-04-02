targetScope = 'resourceGroup'

// ------------------
// PARAMETERS
// ------------------

@description('The name of the vnet. This needs to be unique within the resource group.')
param name string

@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = resourceGroup().location    // or deployment().location if targetScope = 'subscription'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The address prefix for the virtual network.')
param addressPrefix string = '10.0.0.0/16'

@description('Required. The name of the Route Table to create.')
param routeTableName string = 'routetable'



// ------------------
// VARIABLES
// ------------------

// ------------------
// RESOURCES
// ------------------

module nsgs 'deploy.nsg.bicep' = {
  name: take('${name}-nsgs-${deployment().name}', 64)
  params: {    
    // routeTableName: 'dep-${namePrefix}-rt-${serviceShort}'
    networkSecurityGroupName: '${name}-nsg'
    networkSecurityGroupBastionName: '${name}-bastion-nsg'
    location: location
    routeTableName: routeTableName
  }
}


module vnet '../avm/network/virtual-network/main.bicep' = {
  name: take('${name}-${deployment().name}', 64)
  params: {
    name: name
    location: location
    tags: tags
    addressPrefixes: [
      addressPrefix
    ]
    subnets:[
         {
          addressPrefix: cidrSubnet(addressPrefix, 26, 0)
          name: 'AzureBastionSubnet'
          networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupBastionResourceId
        }   
        {
          addressPrefix: cidrSubnet(addressPrefix, 26, 1)
          name: 'snetAksUser02'
          networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupResourceId
        }  
        {
          addressPrefix: cidrSubnet(addressPrefix, 27, 4)
          name: 'snetAppGateway'
          networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupResourceId
        }       
        {
          addressPrefix: cidrSubnet(addressPrefix, 27, 5)
          name: 'snetPe'
          networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupResourceId
        }       
         {
          addressPrefix: cidrSubnet(addressPrefix, 27, 6)
          name: 'snetAksSystem'
          networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupResourceId
        }  
        {
          addressPrefix: cidrSubnet(addressPrefix, 27, 7)
          name: 'snetAksUser01'
          networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupResourceId
        }  
        
        // {
        //   addressPrefix: cidrSubnet(addressPrefix, 24, 1)
        //   name: '${namePrefix}-az-subnet-x-001'
        //   networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupResourceId          
        //   routeTableResourceId: nsgs.outputs.routeTableResourceId
        //   serviceEndpoints: [
        //     {
        //       service: 'Microsoft.Storage'
        //     }
        //     {
        //       service: 'Microsoft.Sql'
        //     }
        //   ]
        // }
        // {
        //   addressPrefix: cidrSubnet(addressPrefix, 24, 2)
        //   delegations: [
        //     {
        //       name: 'netappDel'
        //       properties: {
        //         serviceName: 'Microsoft.Netapp/volumes'
        //       }
        //     }
        //   ]
        //   name: '${namePrefix}-az-subnet-x-002'
        //   networkSecurityGroupResourceId: nsgs.outputs.networkSecurityGroupResourceId
        // }            
      ]
  }
  dependsOn: [
    nsgs
  ]
}


// ------------------
// OUTPUTS
// ------------------

@description('The resource id of the created vnet.')
output vnetResourceId string = vnet.outputs.resourceId

@description('The name of the created vnet.')
output vnetName string = vnet.outputs.name

@description('The resource id of the created subnet for PE and VMs.')
output snetPeResourceId  string = vnet.outputs.subnetResourceIds[3]
