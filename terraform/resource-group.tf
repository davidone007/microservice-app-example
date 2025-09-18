# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-${var.environment}-${local.resource_suffix}"
  location = var.location
  tags     = local.common_tags
}
