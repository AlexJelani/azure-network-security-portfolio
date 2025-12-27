# Lab 02: Configure Network Access to VM

## Overview
Demonstrates network access control with Linux VM, Nginx installation, and NSG rule configuration for SSH and HTTP traffic.

## Quick Deploy
```bash
az group create --name rg-network-access --location eastus
az deployment group create \
  --resource-group rg-network-access \
  --template-file main.bicep \
  --parameters adminUsername=netadmin adminPassword='NetworkLab2024!'
```

## Alternative Deploy (with custom deployment name)
```bash
az deployment group create \
  --resource-group rg-network-access \
  --template-file main.bicep \
  --name network-access-deploy \
  --parameters adminUsername=netadmin adminPassword='NetworkLab2024!'
```

## Resources Created
- Virtual Network (10.0.0.0/16) with subnet (10.0.0.0/24)
- NSG with SSH (22) and HTTP (80) rules
- Ubuntu 20.04 LTS VM with Nginx web server
- Public IP and Network Interface
- Custom Script Extension for automated Nginx setup

## Verification Steps

### 1. Get VM Public IP
```bash
az network public-ip show --resource-group rg-network-access --name network-access-vm-pip --query ipAddress -o tsv
```

### 2. Test SSH Access
```bash
ssh netadmin@[VM-PUBLIC-IP]
```
- Use password: `NetworkLab2024!`
- Verify Nginx status: `sudo systemctl status nginx`

### 3. Test HTTP Access
- Browse to `http://[VM-PUBLIC-IP]`
- Should see "Welcome to Azure!" page

### 4. Verify NSG Rules
```bash
az network nsg rule list --resource-group rg-network-access --nsg-name network-access-vm-nsg --output table
```

## Learning Objectives
- ✅ Configure NSG rules for SSH and HTTP traffic
- ✅ Deploy Linux VM with password authentication
- ✅ Install and configure Nginx web server
- ✅ Demonstrate network access control
- ✅ Automate web server setup with custom scripts

## Security Features
- **Controlled Access**: Only SSH (22) and HTTP (80) ports open
- **Standard SSD**: Cost-effective storage
- **Automated Setup**: Nginx installed via custom script extension
- **Network Isolation**: VM deployed in dedicated VNet/subnet

## Cleanup
```bash
az group delete --name rg-network-access --yes --no-wait
```

## Cost Estimation
- **VM (Standard_B2s)**: ~$0.10-$0.15/hour
- **Storage (30GB SSD)**: ~$4/month
- **Public IP**: ~$3/month
- **Total**: ~$0.12/hour + storage costs