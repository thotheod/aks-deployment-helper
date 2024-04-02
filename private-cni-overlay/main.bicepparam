using './main.bicep'

@description('NAme of the AKS cluster')
param name = 'aks01'

@description('Use availability zones if required and if region supports them.')
param useAvailabilityZones = true


@description('The subnet ID to use for the AKS cluster system node pool.')
param subnetIdAksSystem = '/subscriptions/4f1ba648-9712-4b9c-b5b1-f7aac3ad5cb8/resourceGroups/min999-proj99-dev-rg/providers/Microsoft.Network/virtualNetworks/min999-proj99-dev-vnet/subnets/snetAksSystem'

@description('The subnet ID to use for the AKS cluster user node pool.')
param subnetIdAksUser = '/subscriptions/4f1ba648-9712-4b9c-b5b1-f7aac3ad5cb8/resourceGroups/min999-proj99-dev-rg/providers/Microsoft.Network/virtualNetworks/min999-proj99-dev-vnet/subnets/snetAksUser01'

@description('Optional. Enable Managed NGINX ingress with the application routing add-on for the AKS cluster.')
param applicationRoutingAddOnEnabled = true
