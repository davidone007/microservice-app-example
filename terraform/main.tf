terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "azurerm" {
    # These values will be provided via backend-config during terraform init
    # resource_group_name  = "rg-terraform-state"
    # storage_account_name = "stterraformstate"
    # container_name       = "tfstate"
    # key                  = "microservice-todo.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  resource_suffix = random_id.suffix.hex
  common_tags = {
    Project     = "microservice-todo-app"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Current Azure client configuration
data "azurerm_client_config" "current" {}
