using './main.bicep'

@description('NAme of the AKS cluster')
param name = 'aks01'

@description('Use availability zones if required and if region supports them.')
param useAvailabilityZones = true


@description('The subnet ID to use for the AKS cluster system node pool.')
param subnetIdAksSystem = '/subscriptions/xxxxxxxxxxxxxxxxxxxx/resourceGroups/min999-proj99-dev-rg/providers/Microsoft.Network/virtualNetworks/min999-proj99-dev-vnet/subnets/snetAksSystem'

@description('The subnet ID to use for the AKS cluster user node pool.')
param subnetIdAksUser = '/subscriptions/xxxxxxxxxxxxxxxxxx/resourceGroups/min999-proj99-dev-rg/providers/Microsoft.Network/virtualNetworks/min999-proj99-dev-vnet/subnets/snetAksUser01'

@description('Optional. Enable Managed NGINX ingress with the application routing add-on for the AKS cluster.')
param applicationRoutingAddOnEnabled = true
