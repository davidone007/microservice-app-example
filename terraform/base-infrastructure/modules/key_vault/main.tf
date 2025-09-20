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

resource "azurerm_key_vault_secret" "main" {
  for_each     = nonsensitive(var.secrets)
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.main.id
}
