targetScope = 'resourceGroup'

// ------------------
// PARAMETERS
// ------------------

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
param name string 

@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = resourceGroup().location    // or deployment().location if targetScope = 'subscription'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@allowed([
  'calico'
  'azure'
  'cilium'
])
param networkPolicy string = 'azure'

@description('Optional. Network dataplane used in the Kubernetes cluster. Not compatible with kubenet network plugin.')
@allowed([
  'azure'
  'cilium'
])
param networkDataplane string? 

@description('Use availability zones if required and if region supports them.')
param useAvailabilityZones bool = true

@description('The subnet ID to use for the AKS cluster system node pool.')
param subnetIdAksSystem string

@description('The subnet ID to use for the AKS cluster user node pool.')
param subnetIdAksUser string

@description('Optional. Enable Managed NGINX ingress with the application routing add-on for the AKS cluster.')
param applicationRoutingAddOnEnabled bool 

// ------------------
// VARIABLES
// ------------------
var resourceNames = {
   aksIdenity: '${name}-user-id'
  // vnetName: '${workloadName}-${environment}-vnet'
}


module userAssignedIdentityAks '../avm/managed-identity/managed-identity.bicep' = {
  name: 'userAssignedIdentityAks'
  params: {
    name: resourceNames.aksIdenity
    location: location
    tags: tags
  }
}

// ------------------
// RESOURCES
// ------------------
module aks '../avm/container-service/managed-clutser/main.bicep' = {
  name: 'aks-deployment'
  params: {
    name: name
    location: location
    tags: tags
    skuTier: 'Standard'
    enablePrivateCluster: true
    privateDNSZone: 'system'
    managedIdentities: {
      userAssignedResourcesIds: [
          userAssignedIdentityAks.outputs.id
        ]
    }
    networkPlugin: 'azure'
    networkPluginMode: 'overlay'
    networkPolicy: networkPolicy
    networkDataplane: networkDataplane    
    // serviceCidr: '172.16.0.0/16'
    // dnsServiceIP: '172.16.34.10'
    webApplicationRoutingEnabled: applicationRoutingAddOnEnabled
    
    // We don not need Azure AD authentication with Azure RBAC, plain RBAC should be enough
    aadProfileEnableAzureRBAC: false
    aadProfileManaged: false
    autoUpgradeProfileUpgradeChannel: 'node-image'

    // azureKeyVaultSecretsProvider: enable by default
    enableKeyvaultSecretsProvider: true
    enableSecretRotation: 'true'

    primaryAgentPoolProfile: [
      {        
        name: 'systempool'
        mode: 'System'
        availabilityZones: useAvailabilityZones ? pickZones('Microsoft.Compute', 'virtualMachines',location) : []
        vmSize: 'Standard_DS4_v2' //  https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools
        osType: 'Linux'
        count: 2          
        minCount: 2  
        maxCount: 10
        enableAutoScaling: true
        // maxPods: 30        
        osDiskSizeGB: 80
        scaleSetEvictionPolicy: 'Delete'
        scaleSetPriority: 'Regular'
        type: 'VirtualMachineScaleSets' 
        nodeLabels: {}
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]   
        vnetSubnetID: subnetIdAksSystem
      }      
    ]
    agentPools: [
      {
        name: 'userpool'
        mode: 'User'
        availabilityZones: useAvailabilityZones ? pickZones('Microsoft.Compute', 'virtualMachines',location) : []
        vmSize: 'Standard_D16ds_v5' //  https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools
        osType: 'Linux'
        count: 1      
        minCount: 1 
        maxCount: 10
        enableAutoScaling: true
        // maxPods: 30        
        osDiskSizeGB: 0
        scaleSetEvictionPolicy: 'Delete'
        scaleSetPriority: 'Regular'
        type: 'VirtualMachineScaleSets'         
        vnetSubnetID: subnetIdAksUser
      }
    ]
  }
}


// ------------------
// OUTPUTS
// ------------------
