#!/bin/bash

# Azure Traffic Manager Lab Deployment Script
# This script deploys the complete Traffic Manager lab infrastructure

set -e

# Configuration
EAST_RG="rg-traffic-manager-east"
WEST_RG="rg-traffic-manager-west"
EAST_LOCATION="eastus"
WEST_LOCATION="westus"
ADMIN_USERNAME="azureuser"
ADMIN_PASSWORD="TrafficLab2024!"

echo "🚀 Starting Azure Traffic Manager Lab Deployment"
echo "================================================"

# Check if logged into Azure
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure CLI first: az login"
    exit 1
fi

echo "✅ Azure CLI authenticated"

# Create Resource Groups
echo "📁 Creating resource groups..."
az group create --name $EAST_RG --location $EAST_LOCATION --output none
az group create --name $WEST_RG --location $WEST_LOCATION --output none
echo "✅ Resource groups created"

# Deploy East US Infrastructure
echo "🌐 Deploying East US infrastructure..."
az deployment group create \
    --resource-group $EAST_RG \
    --template-file eastus.bicep \
    --parameters adminUsername=$ADMIN_USERNAME adminPassword=$ADMIN_PASSWORD \
    --output none
echo "✅ East US infrastructure deployed"

# Deploy West US Infrastructure  
echo "🌐 Deploying West US infrastructure..."
az deployment group create \
    --resource-group $WEST_RG \
    --template-file westus.bicep \
    --parameters adminUsername=$ADMIN_USERNAME adminPassword=$ADMIN_PASSWORD \
    --output none
echo "✅ West US infrastructure deployed"

# Wait for VMs to be ready
echo "⏳ Waiting for VMs to complete setup (3 minutes)..."
sleep 180

# Deploy Traffic Manager
echo "🔄 Deploying Traffic Manager profile..."
az deployment group create \
    --resource-group $EAST_RG \
    --template-file traffic-manager.bicep \
    --parameters eastusResourceGroup=$EAST_RG westusResourceGroup=$WEST_RG \
    --output none
echo "✅ Traffic Manager profile deployed"

# Get deployment outputs
echo "📋 Deployment Summary"
echo "===================="

EAST_IP=$(az network public-ip show --resource-group $EAST_RG --name EastUS-WebVM-pip --query ipAddress -o tsv)
WEST_IP=$(az network public-ip show --resource-group $WEST_RG --name WestUS-WebVM-pip --query ipAddress -o tsv)
TM_FQDN=$(az network traffic-manager profile show --resource-group $EAST_RG --name tm-subnet-routing --query dnsConfig.fqdn -o tsv)

echo "🌍 East US VM: http://$EAST_IP"
echo "🌍 West US VM: http://$WEST_IP"
echo "🔄 Traffic Manager: http://$TM_FQDN"
echo ""
echo "🧪 Testing Instructions:"
echo "1. Test individual endpoints first"
echo "2. Test Traffic Manager URL"
echo "3. Use different networks to verify subnet routing"
echo ""
echo "🗑️  Cleanup: ./cleanup.sh"
echo "✅ Lab deployment completed successfully!"