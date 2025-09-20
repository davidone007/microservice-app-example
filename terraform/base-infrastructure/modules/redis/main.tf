resource "azurerm_redis_cache" "main" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = 1
  family                        = "P"
  sku_name                      = "Premium"
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  subnet_id                     = var.subnet_id
  tags                          = var.tags
}
