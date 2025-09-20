output "resource_group_name" {
  description = "Nombre del grupo de recursos."
  value       = module.resource_group.name
}

output "location" {
  description = "Ubicación de los recursos."
  value       = module.resource_group.location
}

output "acr_id" {
  description = "ID del Azure Container Registry."
  value       = module.acr.id
}

output "acr_login_server" {
  description = "Servidor de login del ACR."
  value       = module.acr.login_server
}

output "key_vault_id" {
  description = "ID del Azure Key Vault."
  value       = module.key_vault.id
}

output "key_vault_uri" {
  description = "URI del Azure Key Vault."
  value       = module.key_vault.vault_uri
}

output "log_analytics_workspace_id" {
  description = "ID del Log Analytics Workspace."
  value       = module.log_analytics.id
}

output "log_analytics_primary_shared_key" {
  description = "Clave compartida primaria del Log Analytics Workspace."
  value       = module.log_analytics.primary_shared_key
  sensitive   = true
}

output "vnet_id" {
  description = "ID de la Virtual Network."
  value       = module.networking.vnet_id
}

output "container_apps_subnet_id" {
  description = "ID de la subred para Container Apps."
  value       = module.networking.subnet_ids["container-apps-subnet"]
}
