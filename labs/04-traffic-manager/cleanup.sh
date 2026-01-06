#!/bin/bash

# Azure Traffic Manager Lab Cleanup Script
# This script removes all resources created for the Traffic Manager lab

set -e

# Configuration
EAST_RG="rg-traffic-manager-east"
WEST_RG="rg-traffic-manager-west"

echo "🗑️  Azure Traffic Manager Lab Cleanup"
echo "====================================="

# Check if logged into Azure
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure CLI first: az login"
    exit 1
fi

echo "✅ Azure CLI authenticated"

# Confirm deletion
read -p "⚠️  This will delete ALL resources in $EAST_RG and $WEST_RG. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

# Delete resource groups
echo "🗑️  Deleting East US resource group..."
az group delete --name $EAST_RG --yes --no-wait

echo "🗑️  Deleting West US resource group..."
az group delete --name $WEST_RG --yes --no-wait

echo "✅ Cleanup initiated - resources will be deleted in the background"
echo "📋 You can monitor progress in the Azure Portal"
echo "💡 Tip: Use 'az group list --query \"[?name=='$EAST_RG' || name=='$WEST_RG']\"' to check deletion status"