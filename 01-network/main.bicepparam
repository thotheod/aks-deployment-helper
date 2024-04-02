using './main.bicep'

param addressPrefix = '10.1.0.0/23'

param vmSettings = {
  vmAdminUsername: 'adminuser'
  vmAdminPassword: 'Password1234!'  
  vmSize: 'Standard_D2s_v5'
}
