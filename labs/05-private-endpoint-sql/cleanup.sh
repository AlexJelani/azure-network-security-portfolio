#!/bin/bash

# Lab 05: Private Endpoint for SQL Database - Cleanup Script
# This script removes all resources created for the lab

set -e

# Configuration
RESOURCE_GROUP="rg-lab05-private-endpoint"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧹 Starting cleanup for Lab 05: Private Endpoint for SQL Database${NC}"

# Check if resource group exists
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo -e "${YELLOW}⚠️  Resource group $RESOURCE_GROUP does not exist. Nothing to clean up.${NC}"
    exit 0
fi

# List resources that will be deleted
echo -e "${YELLOW}📋 Resources to be deleted:${NC}"
az resource list --resource-group $RESOURCE_GROUP --output table

echo ""
echo -e "${RED}⚠️  WARNING: This will permanently delete all resources in $RESOURCE_GROUP${NC}"
echo -e "${YELLOW}Do you want to continue? (y/N):${NC}"
read -r CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ Cleanup cancelled${NC}"
    exit 0
fi

# Delete resource group
echo -e "${YELLOW}Deleting resource group: $RESOURCE_GROUP${NC}"
az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait

echo -e "${GREEN}✅ Cleanup initiated. Resources are being deleted in the background.${NC}"
echo -e "${YELLOW}💡 You can monitor progress in the Azure portal or run:${NC}"
echo "az group show --name $RESOURCE_GROUP"