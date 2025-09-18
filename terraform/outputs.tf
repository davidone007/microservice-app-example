# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Container Registry
output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "Login server URL of the Azure Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

# App Services
output "auth_api_hostname" {
  description = "Hostname of the Auth API app service"
  value       = azurerm_linux_web_app.auth_api.default_hostname
}

output "auth_api_url" {
  description = "URL of the Auth API app service"
  value       = "https://${azurerm_linux_web_app.auth_api.default_hostname}"
}

output "users_api_hostname" {
  description = "Hostname of the Users API app service"
  value       = azurerm_linux_web_app.users_api.default_hostname
}

output "users_api_url" {
  description = "URL of the Users API app service"
  value       = "https://${azurerm_linux_web_app.users_api.default_hostname}"
}

output "todos_api_hostname" {
  description = "Hostname of the TODOs API app service"
  value       = azurerm_linux_web_app.todos_api.default_hostname
}

output "todos_api_url" {
  description = "URL of the TODOs API app service"
  value       = "https://${azurerm_linux_web_app.todos_api.default_hostname}"
}

output "log_processor_hostname" {
  description = "Hostname of the Log Processor app service"
  value       = azurerm_linux_web_app.log_processor.default_hostname
}

output "frontend_hostname" {
  description = "Hostname of the Frontend app service"
  value       = azurerm_linux_web_app.frontend.default_hostname
}

output "frontend_url" {
  description = "URL of the Frontend app service"
  value       = "https://${azurerm_linux_web_app.frontend.default_hostname}"
}

# Redis Cache
output "redis_hostname" {
  description = "Hostname of the Redis Cache"
  value       = azurerm_redis_cache.main.hostname
}

output "redis_port" {
  description = "Port of the Redis Cache"
  value       = azurerm_redis_cache.main.ssl_port
}

output "redis_primary_access_key" {
  description = "Primary access key for Redis Cache"
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

# Key Vault
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Network
output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_app_services_id" {
  description = "ID of the app services subnet"
  value       = azurerm_subnet.app_services.id
}

# App Service Names (for deployment)
output "auth_api_name" {
  description = "Name of the Auth API app service"
  value       = azurerm_linux_web_app.auth_api.name
}

output "users_api_name" {
  description = "Name of the Users API app service"
  value       = azurerm_linux_web_app.users_api.name
}

output "todos_api_name" {
  description = "Name of the TODOs API app service"
  value       = azurerm_linux_web_app.todos_api.name
}

output "log_processor_name" {
  description = "Name of the Log Processor app service"
  value       = azurerm_linux_web_app.log_processor.name
}

output "frontend_name" {
  description = "Name of the Frontend app service"
  value       = azurerm_linux_web_app.frontend.name
}
