# Lab 04: Traffic Manager with Subnet-Based Routing

## Overview
Demonstrates Azure Traffic Manager configuration for directing traffic to specific endpoints based on user subnet. This lab implements geographic and subnet-based traffic distribution using DNS-based load balancing across multiple Azure regions.

## Architecture

### Core Infrastructure
- **Resource Groups**: East US and West US regions
- **Virtual Networks**: Regional VNets with web server subnets
- **Traffic Manager Profile**: Subnet routing method
- **Web Servers**: IIS-enabled Windows VMs in each region

### Compute Resources
- **EastUS-WebVM**: Windows Server 2022, Standard_B2s (East US)
- **WestUS-WebVM**: Windows Server 2022, Standard_B2s (West US)
- **Custom IIS Pages**: Region-specific content for testing

### Traffic Management
- **DNS-Based Routing**: Traffic Manager handles DNS resolution
- **Subnet Routing**: Direct traffic based on client subnet
- **Health Monitoring**: Automatic endpoint health checks
- **High Availability**: Multi-region deployment

## Quick Deploy

### 1. Create Resource Groups
```bash
# East US Resource Group
az group create --name rg-traffic-manager-east --location eastus

# West US Resource Group  
az group create --name rg-traffic-manager-west --location westus
```

### 2. Deploy East US Infrastructure
```bash
az deployment group create \
  --resource-group rg-traffic-manager-east \
  --template-file eastus.bicep \
  --parameters adminUsername=azureuser adminPassword='TrafficLab2024!'
```

### 3. Deploy West US Infrastructure
```bash
az deployment group create \
  --resource-group rg-traffic-manager-west \
  --template-file westus.bicep \
  --parameters adminUsername=azureuser adminPassword='TrafficLab2024!'
```

### 4. Deploy Traffic Manager Profile
```bash
az deployment group create \
  --resource-group rg-traffic-manager-east \
  --template-file traffic-manager.bicep \
  --parameters eastusResourceGroup=rg-traffic-manager-east westusResourceGroup=rg-traffic-manager-west
```

## Verification Steps

### 1. Get Traffic Manager DNS Name
```bash
az network traffic-manager profile show \
  --resource-group rg-traffic-manager-east \
  --name tm-subnet-routing \
  --query dnsConfig.fqdn -o tsv
```

### 2. Test Web Server Endpoints
```bash
# Get VM public IPs
EAST_IP=$(az network public-ip show --resource-group rg-traffic-manager-east --name EastUS-WebVM-pip --query ipAddress -o tsv)
WEST_IP=$(az network public-ip show --resource-group rg-traffic-manager-west --name WestUS-WebVM-pip --query ipAddress -o tsv)

echo "East US VM: http://$EAST_IP"
echo "West US VM: http://$WEST_IP"
```

### 3. Test Traffic Manager Routing
```bash
# Get Traffic Manager FQDN
TM_FQDN=$(az network traffic-manager profile show \
  --resource-group rg-traffic-manager-east \
  --name tm-subnet-routing \
  --query dnsConfig.fqdn -o tsv)

echo "Traffic Manager URL: http://$TM_FQDN"

# Test DNS resolution
nslookup $TM_FQDN
```

### 4. Verify Endpoint Health
```bash
az network traffic-manager endpoint list \
  --resource-group rg-traffic-manager-east \
  --profile-name tm-subnet-routing \
  --query '[].{Name:name,Status:endpointStatus,Health:endpointMonitorStatus}' -o table
```

## Learning Objectives

### Traffic Management
- ✅ Configure DNS-based load balancing
- ✅ Implement subnet-based routing
- ✅ Set up multi-region endpoints
- ✅ Monitor endpoint health status

### Network Security
- ✅ Regional network isolation
- ✅ HTTP/HTTPS endpoint configuration
- ✅ NSG rules for web traffic
- ✅ Public IP and DNS management

### Infrastructure as Code
- ✅ Multi-region Bicep deployments
- ✅ Traffic Manager profile automation
- ✅ Endpoint configuration management
- ✅ Resource dependency handling

## Traffic Manager Features

### Routing Methods
- **Subnet Routing**: Direct traffic based on client IP ranges
- **Geographic Routing**: Route by user geographic location
- **Performance Routing**: Route to closest endpoint
- **Weighted Routing**: Distribute traffic by percentage

### Health Monitoring
- **HTTP/HTTPS Probes**: Automatic endpoint health checks
- **Custom Probe Paths**: Monitor specific application endpoints
- **Failover Support**: Automatic traffic redirection on failure
- **Health Status**: Real-time endpoint monitoring

### DNS Configuration
- **Custom DNS Names**: Branded Traffic Manager URLs
- **TTL Settings**: DNS cache control
- **CNAME Records**: Custom domain integration
- **Global Availability**: Worldwide DNS resolution

## Testing Scenarios

### 1. Basic Connectivity Test
```bash
# Test direct VM access
curl -I http://$EAST_IP
curl -I http://$WEST_IP

# Test Traffic Manager routing
curl -I http://$TM_FQDN
```

### 2. Subnet Routing Verification
```bash
# Check which endpoint is being used
dig $TM_FQDN

# Test from different networks to verify routing
# (Results will vary based on client subnet configuration)
```

### 3. Endpoint Failover Test
```bash
# Stop one VM to test failover
az vm stop --resource-group rg-traffic-manager-east --name EastUS-WebVM

# Wait for health probe to detect failure (2-3 minutes)
# Test Traffic Manager response
curl http://$TM_FQDN
```

## Troubleshooting

### Traffic Manager Issues
1. **DNS Resolution**: Verify Traffic Manager FQDN resolves correctly
2. **Endpoint Health**: Check endpoint monitor status
3. **Routing Rules**: Confirm subnet routing configuration
4. **Probe Settings**: Verify health probe path and protocol

### Web Server Issues
1. **IIS Status**: Ensure IIS is running on both VMs
2. **Firewall Rules**: Verify Windows Firewall allows HTTP
3. **NSG Rules**: Check network security group configuration
4. **VM Status**: Confirm VMs are running and accessible

### Network Connectivity
1. **Public IPs**: Verify public IP assignment
2. **DNS Names**: Check DNS label configuration
3. **Port Access**: Ensure port 80/443 is accessible
4. **Regional Connectivity**: Test cross-region communication

## Cost Estimation
- **VMs (2x Standard_B2s)**: ~$0.332/hour
- **Traffic Manager Profile**: ~$0.54/month + queries
- **Public IPs (2x Basic)**: ~$0.004/hour
- **Network**: Minimal charges for VNet/NSG
- **Total**: ~$0.34/hour + Traffic Manager usage

## Cleanup
```bash
# Delete resource groups (includes all resources)
az group delete --name rg-traffic-manager-east --yes --no-wait
az group delete --name rg-traffic-manager-west --yes --no-wait
```

## Prerequisites
- Azure CLI installed and configured
- Active Azure subscription with Contributor access
- Logged into Azure CLI (`az login`)
- DNS tools for testing (dig, nslookup)

## Related AZ-500 Exam Topics
- **Network Security**: DNS-based load balancing, endpoint security
- **High Availability**: Multi-region deployment, failover configuration
- **Traffic Management**: Routing methods, health monitoring
- **Infrastructure Security**: Regional isolation, secure endpoints

## Duration
**Estimated Time**: 90 minutes
- Infrastructure deployment: 30 minutes
- Traffic Manager configuration: 20 minutes
- Testing and validation: 30 minutes
- Cleanup and documentation: 10 minutes