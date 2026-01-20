output "container_app_id" {
  description = "The ID of the container app"
  value       = azurerm_container_app.main.id
}

output "container_app_name" {
  description = "The name of the container app"
  value       = azurerm_container_app.main.name
}

output "container_app_fqdn" {
  description = "The FQDN of the container app"
  value       = try(azurerm_container_app.main.ingress[0].fqdn, null)
}

output "latest_revision_name" {
  description = "The latest revision name"
  value       = azurerm_container_app.main.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "The latest revision FQDN"
  value       = azurerm_container_app.main.latest_revision_fqdn
}
