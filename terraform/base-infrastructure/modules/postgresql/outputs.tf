
output "db_server_id" {
  value = azurerm_postgresql_flexible_server.main.id
}

output "db_name" {
  value = azurerm_postgresql_flexible_server_database.main.name
}

output "db_server_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "db_admin_username" {
  value = azurerm_postgresql_flexible_server.main.administrator_login
}
