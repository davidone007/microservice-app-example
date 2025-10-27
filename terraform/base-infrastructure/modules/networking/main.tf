resource "azurerm_virtual_network" "main" {
  name                = "vnet-microservices"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value]

  dynamic "delegation" {
    for_each = each.key == "postgresql-subnet" ? [1] : []
    content {
      name = "postgresql-flexible-server"
      service_delegation {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

