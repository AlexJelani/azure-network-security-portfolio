# Lab 03: Storage Security with Service Endpoints

## Overview
Demonstrates Azure Storage Account security using Virtual Network service endpoints, network access control lists, and least-privilege networking principles. This lab implements a secure storage architecture where access is restricted to specific subnets.

## Architecture

### Core Infrastructure
- **Resource Group**: Deployed in East US
- **Virtual Network**: CoreServicesVNet (10.0.0.0/16)
- **Subnet**: Private (10.0.1.0/24) with Microsoft.Storage service endpoint
- **Storage Account**: Network rules configured with defaultAction = Deny

### Compute Resources
- **ContosoPublic VM**: Windows Server 2022, Standard_B2s
- **ContosoPrivate VM**: Windows Server 2022, Standard_B2s
- Each VM includes dedicated NIC, NSG, and Public IP

### Security Controls
- **Storage Network ACLs**: Deny all traffic except from Private subnet
- **Service Endpoints**: Secure, optimized connectivity to Azure Storage
- **NSG Rules**: RDP access control at NIC level
- **Least Privilege**: Minimal required permissions and network access

## Quick Deploy

### 1. Create Resource Group
```bash
az group create --name rg-storage-security --location eastus
```

### 2. Deploy Infrastructure
```bash
az deployment group create \
  --resource-group rg-storage-security \
  --template-file main.bicep \
  --parameters adminUsername=azureuser adminPassword='StorageLab2024!'
```

### 3. Alternative Deploy with Parameters File
```bash
az deployment group create \
  --resource-group rg-storage-security \
  --template-file main.bicep \
  --parameters @main.parameters.json
```

## Verification Steps

### 1. Get Deployment Outputs
```bash
az deployment group show \
  --resource-group rg-storage-security \
  --name main \
  --query properties.outputs
```

### 2. Test Storage Access from VMs

#### Connect to ContosoPrivate VM
```bash
# Get VM public IP
PRIVATE_VM_IP=$(az network public-ip show --resource-group rg-storage-security --name ContosoPrivate-pip --query ipAddress -o tsv)

# RDP to VM (use Remote Desktop client)
echo "Connect to: $PRIVATE_VM_IP"
```

#### Test Storage Access from VM
From within the VM, open PowerShell and test storage connectivity:
```powershell
# Get storage account name
$storageAccount = (Get-AzStorageAccount -ResourceGroupName rg-storage-security).StorageAccountName

# Test storage access (should succeed from Private subnet)
$ctx = New-AzStorageContext -StorageAccountName $storageAccount -UseConnectedAccount
Get-AzStorageContainer -Context $ctx
```

### 3. Verify Network Rules
```bash
# Check storage account network rules
az storage account show \
  --resource-group rg-storage-security \
  --name $(az storage account list --resource-group rg-storage-security --query '[0].name' -o tsv) \
  --query networkRuleSet
```

### 4. Test External Access (Should Fail)
```bash
# Attempt to access storage from local machine (should be denied)
STORAGE_NAME=$(az storage account list --resource-group rg-storage-security --query '[0].name' -o tsv)
az storage container list --account-name $STORAGE_NAME --auth-mode login
```

## Learning Objectives

### Network Security
- ✅ Configure Virtual Network service endpoints
- ✅ Implement storage account network ACLs
- ✅ Apply least-privilege network access
- ✅ Secure storage connectivity without internet routing

### Infrastructure as Code
- ✅ Bicep template development
- ✅ Secure parameter handling
- ✅ Resource dependency management
- ✅ Enterprise naming conventions

### Security Best Practices
- ✅ Network-level storage protection
- ✅ Service endpoint security benefits
- ✅ Defense in depth implementation
- ✅ Access control validation

## Security Features

### Storage Security
- **Network ACLs**: Default deny with subnet-specific allow rules
- **Service Endpoints**: Private connectivity without internet exposure
- **HTTPS Only**: Encrypted data transmission enforced
- **Public Access**: Blob public access disabled

### Network Security
- **Subnet Isolation**: Dedicated subnet with service endpoints
- **NSG Protection**: Network security groups at NIC level
- **Controlled Access**: Only required ports (RDP) opened
- **Basic SKU**: Cost-optimized for demos and labs

### Identity & Access
- **Secure Parameters**: Password stored as SecureString
- **Least Privilege**: Minimal required permissions
- **Resource Isolation**: Dedicated NICs and NSGs per VM

## Troubleshooting

### Storage Access Issues
1. **Verify service endpoint**: Check subnet configuration
2. **Check network rules**: Confirm storage account ACLs
3. **VM subnet**: Ensure VM is in correct subnet
4. **Authentication**: Verify Azure AD or access key permissions

### Connectivity Issues
1. **NSG rules**: Verify RDP (3389) is allowed
2. **Public IP**: Confirm Basic SKU assignment
3. **VM status**: Check VM is running and accessible

## Cost Estimation
- **VMs (2x Standard_B2s)**: ~$0.166/hour
- **Storage (Standard_LRS)**: ~$0.003/hour
- **Public IPs (2x Basic)**: ~$0.002/hour
- **Network**: Minimal charges for VNet/NSG
- **Total**: ~$0.17/hour

## Cleanup
```bash
az group delete --name rg-storage-security --yes --no-wait
```

## Prerequisites
- Azure CLI installed and configured
- Active Azure subscription with Contributor access
- Logged into Azure CLI (`az login`)
- Remote Desktop client for VM access

## Related AZ-500 Exam Topics
- **Network Security**: Service endpoints, storage security
- **Data Protection**: Storage account security, network ACLs
- **Identity Management**: VM authentication, secure parameters
- **Infrastructure Security**: Network isolation, least privilege