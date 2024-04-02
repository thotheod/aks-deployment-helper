
# Basic how-to use this helper to create an AKS cluster

The idea is that using the [AVM modules](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res) (or [CARMEL](https://github.com/Azure/ResourceModules) for resources not migrated yet), we can simplify the AKS creation cluster with pre-defined configurations, so that the number of parameters required by the end user to be minimized.
We might end up with some scenarios like the ones outlined below:
- Private AKS with CNI Overlay
- Private AKS with Kubenet
- Private AKS with Azure Application Gateway for Containers etc - we will see how this will be finalized

## Pre-requisites
For sure we will need some resources to get us started, like a VNET, a subnet, a service principal, a storage account for the BLOB storage, a KeyVault for the secrets, a Log Analytics workspace for the monitoring, a container registry for the images, etc. We will see how we can automate the creation of these resources as well.

### Bicep File Structure

``` bicep
targetScope = 'resourceGroup'

// ------------------
// PARAMETERS
// ------------------

@description('The name of the workload that is being deployed. Up to 10 characters long.')
@minLength(2)
@maxLength(20)
param workloadName string = 'min999-proj99'

@description('The location where the resources will be created. This needs to be the same region as the spoke.')
param location string = resourceGroup().location    // or deployment().location if targetScope = 'subscription'

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('The name of the environment (e.g. "dev", "test", "prod", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environment string = 'dev'

// ------------------
// VARIABLES
// ------------------
var resourceNames = {
  rgName: '${workloadName}-${environment}-rg'
  vnetName: '${workloadName}-${environment}-vnet'
}


// ------------------
// RESOURCES
// ------------------


// ------------------
// OUTPUTS
// ------------------

```