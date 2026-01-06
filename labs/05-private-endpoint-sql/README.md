# Lab 05: Private Endpoint for SQL Database

## Overview
This lab demonstrates how to create a private endpoint to securely access an Azure SQL Database from a virtual machine using Azure Bicep templates.

**Duration**: ~90 minutes  
**Focus**: Private endpoints, Azure SQL Database security, network isolation  
**Skills**: Private Link, DNS configuration, secure database connectivity

## Architecture
- Virtual Network with private subnet
- Azure SQL Database with private endpoint
- Windows VM for testing connectivity
- Private DNS zone for name resolution
- Network Security Group for traffic control

## Learning Objectives
- Understand private endpoint concepts
- Configure Azure SQL Database with private connectivity
- Implement secure database access patterns
- Test private endpoint functionality

## Prerequisites
- Azure CLI installed and configured
- Active Azure subscription with contributor access
- Logged into Azure CLI (`az login`)

## Deployment Steps

### 1. Clone and Navigate
```bash
git clone <repository-url>
cd azure-network-security-portfolio/labs/05-private-endpoint-sql
```

### 2. Deploy Infrastructure
```bash
# Create resource group
az group create --name rg-lab05-private-endpoint --location eastus

# Deploy Bicep template
az deployment group create \
  --resource-group rg-lab05-private-endpoint \
  --template-file main.bicep \
  --parameters sqlAdministratorLogin=azureuser sqlAdministratorLoginPassword='YourSecurePassword123!' vmAdminUsername=azureuser vmAdminPassword='YourSecurePassword123!'
```

### 3. Test Private Endpoint

#### Connect to VM
1. Get VM public IP from Azure portal
2. RDP to the VM using provided credentials
3. Open SQL Server Management Studio or Azure Data Studio

#### Test Database Connection
```sql
-- Connection string format:
-- Server: <sql-server-name>.database.windows.net
-- Use SQL Server Authentication with provided credentials
```

### 4. Validation Tests

#### Test 1: Private IP Resolution
```powershell
# On the VM, test DNS resolution
nslookup <sql-server-name>.database.windows.net
# Should resolve to private IP (10.0.1.x)
```

#### Test 2: Network Connectivity
```powershell
# Test connection to SQL Server
Test-NetConnection -ComputerName <sql-server-name>.database.windows.net -Port 1433
```

#### Test 3: Database Query
```sql
-- Connect via SSMS/Azure Data Studio and run:
SELECT @@VERSION;
SELECT DB_NAME();
```

## Cleanup
```bash
# Delete the resource group and all resources
az group delete --name rg-lab05-private-endpoint --yes --no-wait
```

## Key Concepts Demonstrated
- **Private Endpoint**: Network interface connecting VNet to SQL Database
- **Private DNS Zone**: Resolves database FQDN to private IP
- **Network Isolation**: Database accessible only from VNet
- **Secure Connectivity**: No internet exposure for database traffic

## Troubleshooting
- Ensure VM is in the same VNet as private endpoint
- Verify private DNS zone is linked to VNet
- Check NSG rules allow SQL traffic (port 1433)
- Confirm SQL Server firewall allows VNet access

## Cost Estimation
**Estimated hourly cost**: ~$0.85/hour (~$20/day)

| Resource | SKU/Tier | Est. Cost/Hour |
|----------|----------|----------------|
| VM (Standard_B2s) | 2 vCPU, 4GB RAM | $0.041 |
| SQL Database | Basic (2GB) | $0.008 |
| Private Endpoint | Standard | $0.010 |
| Public IP | Standard Static | $0.005 |
| Storage (OS Disk) | Standard LRS 127GB | $0.008 |
| VNet, NSG, DNS Zone | - | Minimal |
| **Total** | | **~$0.072/hour** |

*Costs based on East US region, subject to change. Use [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for current rates.*

**💡 Cost Tips**: Delete resources immediately after testing to minimize charges.