#!/bin/bash

# Lab 05: Private Endpoint for SQL Database - Deployment Script
# This script deploys the infrastructure for testing private endpoints with Azure SQL Database

set -e

# Configuration
RESOURCE_GROUP="rg-lab05-private-endpoint"
LOCATION="eastus"
ADMIN_USERNAME="azureuser"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Lab 05: Private Endpoint for SQL Database${NC}"

# Check if logged into Azure
echo -e "${YELLOW}Checking Azure CLI login status...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Not logged into Azure CLI. Please run 'az login' first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI login confirmed${NC}"

# Prompt for admin password
echo -e "${YELLOW}Enter admin password for VM and SQL Server:${NC}"
read -s ADMIN_PASSWORD

if [ ${#ADMIN_PASSWORD} -lt 12 ]; then
    echo -e "${RED}❌ Password must be at least 12 characters long${NC}"
    exit 1
fi

# Create resource group
echo -e "${YELLOW}Creating resource group: $RESOURCE_GROUP${NC}"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output table

# Deploy Bicep template
echo -e "${YELLOW}Deploying infrastructure with Bicep template...${NC}"
DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters adminUsername=$ADMIN_USERNAME adminPassword="$ADMIN_PASSWORD" \
    --query 'properties.outputs' \
    --output json)

# Extract outputs
VM_PUBLIC_IP=$(echo $DEPLOYMENT_OUTPUT | jq -r '.vmPublicIp.value')
SQL_SERVER_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.sqlServerName.value')
SQL_DATABASE_NAME=$(echo $DEPLOYMENT_OUTPUT | jq -r '.sqlDatabaseName.value')
PRIVATE_ENDPOINT_IP=$(echo $DEPLOYMENT_OUTPUT | jq -r '.privateEndpointIp.value')

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo -e "${GREEN}📋 Lab Resources Created:${NC}"
echo -e "Resource Group: $RESOURCE_GROUP"
echo -e "VM Public IP: $VM_PUBLIC_IP"
echo -e "SQL Server: $SQL_SERVER_NAME.database.windows.net"
echo -e "SQL Database: $SQL_DATABASE_NAME"
echo -e "Private Endpoint IP: $PRIVATE_ENDPOINT_IP"
echo ""
echo -e "${YELLOW}🔗 Next Steps:${NC}"
echo "1. RDP to VM using: $VM_PUBLIC_IP"
echo "2. Username: $ADMIN_USERNAME"
echo "3. Password: [the password you entered]"
echo "4. Install SQL Server Management Studio or Azure Data Studio"
echo "5. Connect to: $SQL_SERVER_NAME.database.windows.net"
echo ""
echo -e "${YELLOW}🧪 Testing Commands (run on VM):${NC}"
echo "nslookup $SQL_SERVER_NAME.database.windows.net"
echo "Test-NetConnection -ComputerName $SQL_SERVER_NAME.database.windows.net -Port 1433"
echo ""
echo -e "${GREEN}🎯 Lab 05 is ready for testing!${NC}"