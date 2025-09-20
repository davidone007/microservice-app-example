terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg-microservices"
    storage_account_name = "tfstatemsapp20250919"
    container_name       = "tfstate"
    key                  = "container-apps.terraform.tfstate"
  }
}
