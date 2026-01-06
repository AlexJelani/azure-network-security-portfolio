@description('Resource group containing East US resources')
param eastusResourceGroup string

@description('Resource group containing West US resources')
param westusResourceGroup string

@description('Traffic Manager profile name')
param trafficManagerName string = 'tm-subnet-routing'

@description('Unique DNS name for Traffic Manager')
param dnsName string = 'tm-${uniqueString(resourceGroup().id)}'

// Get existing East US public IP
resource eastusPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' existing = {
  name: 'EastUS-WebVM-pip'
  scope: resourceGroup(eastusResourceGroup)
}

// Get existing West US public IP
resource westusPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' existing = {
  name: 'WestUS-WebVM-pip'
  scope: resourceGroup(westusResourceGroup)
}

// Traffic Manager Profile
resource trafficManagerProfile 'Microsoft.Network/trafficManagerProfiles@2022-04-01' = {
  name: trafficManagerName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Subnet'
    dnsConfig: {
      relativeName: dnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
      intervalInSeconds: 30
      toleratedNumberOfFailures: 3
      timeoutInSeconds: 10
    }
    endpoints: [
      {
        name: 'EastUS-Endpoint'
        type: 'Microsoft.Network/trafficManagerProfiles/ExternalEndpoints'
        properties: {
          target: eastusPublicIP.properties.dnsSettings.fqdn
          endpointStatus: 'Enabled'
          weight: 1
          priority: 1
          subnets: [
            {
              first: '10.0.0.0'
              scope: 16
            }
            {
              first: '172.16.0.0'
              scope: 12
            }
          ]
        }
      }
      {
        name: 'WestUS-Endpoint'
        type: 'Microsoft.Network/trafficManagerProfiles/ExternalEndpoints'
        properties: {
          target: westusPublicIP.properties.dnsSettings.fqdn
          endpointStatus: 'Enabled'
          weight: 1
          priority: 2
          subnets: [
            {
              first: '192.168.0.0'
              scope: 16
            }
            {
              first: '0.0.0.0'
              scope: 0
            }
          ]
        }
      }
    ]
  }
}

// Outputs
output trafficManagerFQDN string = trafficManagerProfile.properties.dnsConfig.fqdn
output trafficManagerName string = trafficManagerProfile.name
output eastusEndpoint string = eastusPublicIP.properties.dnsSettings.fqdn
output westusEndpoint string = westusPublicIP.properties.dnsSettings.fqdn