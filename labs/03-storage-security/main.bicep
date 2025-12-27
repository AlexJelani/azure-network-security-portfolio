@description('Admin username for VMs')
param adminUsername string

@description('Admin password for VMs')
@secure()
param adminPassword string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Unique suffix for resource names')
param uniqueSuffix string = uniqueString(resourceGroup().id)

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'CoreServicesVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'Private'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [location]
            }
          ]
        }
      }
    ]
  }
}

// Storage Account with network restrictions
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stg${uniqueSuffix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/Private'
          action: 'Allow'
        }
      ]
    }
  }
}

// Public IPs
resource publicIpPublic 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'ContosoPublic-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource publicIpPrivate 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'ContosoPrivate-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Network Security Groups
resource nsgPublic 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'ContosoPublic-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsgPrivate 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'ContosoPrivate-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Network Interfaces
resource nicPublic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'ContosoPublic-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpPublic.id
          }
          subnet: {
            id: '${vnet.id}/subnets/Private'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgPublic.id
    }
  }
}

resource nicPrivate 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'ContosoPrivate-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpPrivate.id
          }
          subnet: {
            id: '${vnet.id}/subnets/Private'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgPrivate.id
    }
  }
}

// Virtual Machines
resource vmPublic 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'ContosoPublic'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'ContosoPublic'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
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
          id: nicPublic.id
        }
      ]
    }
  }
}

resource vmPrivate 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'ContosoPrivate'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'ContosoPrivate'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
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
          id: nicPrivate.id
        }
      ]
    }
  }
}

// Outputs
output resourceGroupName string = resourceGroup().name
output vnetName string = vnet.name
output storageAccountName string = storageAccount.name
output publicVmName string = vmPublic.name
output privateVmName string = vmPrivate.name
output publicVmPublicIp string = publicIpPublic.properties.ipAddress
output privateVmPublicIp string = publicIpPrivate.properties.ipAddress