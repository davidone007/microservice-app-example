output "storage_account_name" {
  description = "El nombre de la cuenta de almacenamiento para el estado de Terraform."
  value       = azurerm_storage_account.tfstate.name
}

output "resource_group_name" {
  description = "El nombre del grupo de recursos para el estado de Terraform."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_container_name" {
  description = "El nombre del contenedor de almacenamiento para el estado de Terraform."
  value       = azurerm_storage_container.tfstate.name
}
