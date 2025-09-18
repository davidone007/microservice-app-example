resource "azurerm_container_registry" "main" {
  name                = "acr${var.app_name}${var.environment}${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = true

  tags = local.common_tags

  identity {
    type = "SystemAssigned"
  }

  # Enable content trust and vulnerability scanning for production
  dynamic "trust_policy" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      enabled = true
    }
  }
}
