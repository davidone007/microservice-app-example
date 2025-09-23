output "id" { value = azurerm_key_vault.main.id }
output "vault_uri" { value = azurerm_key_vault.main.vault_uri }
output "jwt_secret_uri" {
  description = "The URI of the JWT secret in Key Vault."
  value       = azurerm_key_vault_secret.jwt_secret.id
}


