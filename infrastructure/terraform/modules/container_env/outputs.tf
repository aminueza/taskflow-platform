output "environment_id" {
  description = "Container App Environment ID"
  value       = azurerm_container_app_environment.main.id
}

output "environment_name" {
  description = "Container App Environment Name"
  value       = azurerm_container_app_environment.main.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "default_domain" {
  description = "Default domain for the Container App Environment"
  value       = azurerm_container_app_environment.main.default_domain
}
