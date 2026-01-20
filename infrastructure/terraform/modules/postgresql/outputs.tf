output "server_id" {
  description = "PostgreSQL server ID"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "server_name" {
  description = "PostgreSQL server name"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${var.admin_username}:${var.admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${var.databases[0]}?sslmode=require"
  sensitive   = true
}

output "database_names" {
  description = "Created database names"
  value       = [for db in azurerm_postgresql_flexible_server_database.databases : db.name]
}
