output "fqdn" {
  description = "El FQDN (nombre de dominio completo) de la Container App."
  value       = azurerm_container_app.main.latest_revision_fqdn
}
