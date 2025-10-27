output "resource_group_name" {
  description = "Name of the resource group for tfstate"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage account name created for tfstate"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Blob container name used for tfstate"
  value       = azurerm_storage_container.tfstate.name
}

output "key" {
  description = "Default blob key (file name) to use for tfstate"
  value       = var.key
}

