provider "azurerm" {
  subscription_id = "256bea1e-51c0-4409-97c4-118ae42d16dc"
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-rg-microservices"
  location = "East US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstatemsapp20250919" # ¡Cambia esto a un nombre único globalmente!
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
