#!/bin/bash

# Script to setup Terraform backend in Azure
# Run this once before running Terraform

set -e

# Variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="stterraformstate$(openssl rand -hex 4)"
CONTAINER_NAME="tfstate"
LOCATION="East US"

echo "Creating resource group for Terraform state..."
az group create --name $RESOURCE_GROUP_NAME --location "$LOCATION"

echo "Creating storage account for Terraform state..."
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --encryption-services blob

echo "Getting storage account key..."
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

echo "Creating storage container..."
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $ACCOUNT_KEY

echo "Terraform backend setup complete!"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container: $CONTAINER_NAME"
echo ""
echo "Add these as GitHub secrets:"
echo "TERRAFORM_STATE_RG=$RESOURCE_GROUP_NAME"
echo "TERRAFORM_STATE_STORAGE=$STORAGE_ACCOUNT_NAME"
echo "TERRAFORM_STATE_CONTAINER=$CONTAINER_NAME"