output "id" {
  description = "The ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_id" {
  description = "The GUID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "primary_shared_key" {
  description = "The primary shared key of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}
