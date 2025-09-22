resource "azurerm_key_vault" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id # Da acceso al usuario/principal que ejecuta terraform
    secret_permissions = [
      "Get", "List", "Set", "Delete"
    ]
  }
  tags = var.tags
}

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  value        = var.jwt_secret
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "redis_connection_string" {
  name         = "redis-connection-string"
  value        = var.redis_primary_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "redis_host" {
  name         = "redis-host"
  value        = var.redis_hostname
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "redis_port" {
  name         = "redis-port"
  value        = tostring(var.redis_ssl_port)
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "redis_password" {
  name         = "redis-password"
  value        = var.redis_primary_access_key
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "db_host" {
  name         = "db-host"
  value        = var.postgresql_db_server_name
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "db-name"
  value        = var.postgresql_db_name
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = var.postgresql_db_admin_username
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_admin_password
  key_vault_id = azurerm_key_vault.main.id
}
