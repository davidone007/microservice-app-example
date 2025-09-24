provider "azurerm" {
  subscription_id = "b05f5d22-9a6a-4a96-b58d-8d90aebd2986"
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  name                = var.log_analytics_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

module "acr" {
  source              = "./modules/acr"
  name                = var.acr_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

module "key_vault" {
  source                          = "./modules/key_vault"
  name                            = "${var.key_vault_name}-${random_integer.suffix.result}"
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  object_id                       = data.azurerm_client_config.current.object_id
  tags                            = var.tags
  jwt_secret                      = var.jwt_secret
}

