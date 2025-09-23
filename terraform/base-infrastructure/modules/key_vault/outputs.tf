output "id" { value = azurerm_key_vault.main.id }
output "vault_uri" { value = azurerm_key_vault.main.vault_uri }
output "jwt_secret_uri" {
  description = "The URI of the JWT secret in Key Vault."
  value       = azurerm_key_vault_secret.jwt_secret.id
}

output "postgresql_admin_password_uri" {
  description = "The URI of the PostgreSQL admin password secret in Key Vault."
  value       = azurerm_key_vault_secret.db_password.id
}
