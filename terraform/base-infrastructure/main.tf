provider "azurerm" {
  subscription_id = "256bea1e-51c0-4409-97c4-118ae42d16dc"
  features {}
}

data "azurerm_client_config" "current" {}

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

module "redis" {
  source              = "./modules/redis"
  name                = var.redis_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.networking.subnet_ids["redis-subnet"]
  tags                = var.tags
}

module "key_vault" {
  source              = "./modules/key_vault"
  name                = var.key_vault_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  tags                = var.tags

  secrets = {
    "jwt-secret"              = var.jwt_secret,
    "redis-connection-string" = module.redis.primary_connection_string,
    "redis-host"              = module.redis.hostname,
    "redis-port"              = tostring(module.redis.ssl_port),
    "redis-password"          = module.redis.primary_access_key,
    "db-host"                 = module.postgresql.db_server_name,
    "db-name"                 = module.postgresql.db_name,
    "db-user"                 = module.postgresql.db_admin_username,
    "db-password"             = var.db_admin_password
  }
}

module "postgresql" {
  source              = "./modules/postgresql"
  db_server_name      = var.db_server_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password
  db_name             = var.db_name
  delegated_subnet_id = module.networking.subnet_ids["postgresql-subnet"]
  virtual_network_id  = module.networking.vnet_id
}
