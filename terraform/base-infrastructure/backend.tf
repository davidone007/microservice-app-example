terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg-microservices"
    storage_account_name = "tfstatemsapp20250920ac"
    container_name       = "tfstate"
    key                  = "base-infra.terraform.tfstate"
  }
}
