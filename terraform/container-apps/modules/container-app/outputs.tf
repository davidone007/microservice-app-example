output "fqdn" {
  description = "El FQDN (nombre de dominio completo) de la Container App."
  value       = azurerm_container_app.main.latest_revision_fqdn
}

output "principal_id" {
  description = "The principal ID of the system assigned identity of the Container App."
  value       = azurerm_container_app.main.identity[0].principal_id
}
