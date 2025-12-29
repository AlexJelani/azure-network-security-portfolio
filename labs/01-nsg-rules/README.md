# Lab 01: Network Security Group Rules

## Overview
Demonstrates NSG configuration and secure VM deployment with automated IIS installation.

## Quick Deploy
```bash
az group create --name rg-nsg-lab --location westeurope
az deployment group create \
  --resource-group rg-nsg-lab \
  --template-file main.bicep \
  --parameters adminUsername=nsgadmin adminPassword='NsgLab2024!'
```

## Alternative Deploy (with custom deployment name)
```bash
az deployment group create \
  --resource-group rg-nsg-lab \
  --template-file main.bicep \
  --name nsg-lab-deploy \
  --parameters adminUsername=nsgadmin adminPassword='NsgLab2024!'
```

## Resources Created
- Virtual Network (10.0.0.0/16)
- NSG with RDP (3389) and HTTP (80) rules
- Windows Server 2022 VM with IIS
- Public IP and Network Interface

## Verification
1. Get public IP: `az network public-ip show --resource-group rg-nsg-lab --name nsg-lab-vm-pip --query ipAddress -o tsv`
2. RDP to VM public IP with credentials above
3. Browse to `http://[VM-PUBLIC-IP]` to see IIS page

## Security Assessment
Run ScoutSuite to validate NSG configuration and security posture:
```bash
# Install ScoutSuite (if not already installed)
pip install scoutsuite

# Run security assessment
scout azure --cli --report-dir ./scout-report

# View results
open ./scout-report/azure-tenant-*.html
```

**Expected Results:**
- Network security rules analysis
- VM security configuration review
- NSG effectiveness validation
- Overall security score and recommendations

## Cleanup
```bash
az group delete --name rg-nsg-lab --yes --no-wait
```