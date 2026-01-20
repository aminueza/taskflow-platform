##########################################################
#                   CONTAINER APPS OUTPUTS               #
##########################################################

output "container_apps" {
  description = "Map of deployed container apps"
  value = {
    for key, app in module.container_apps : key => {
      name = app.container_app_name
      fqdn = app.container_app_fqdn
      url  = "https://${app.container_app_fqdn}"
      id   = app.container_app_id
    }
  }
}

output "container_app_urls" {
  description = "List of container app URLs"
  value = {
    for key, app in module.container_apps : key => "https://${app.container_app_fqdn}"
  }
}

output "resource_group_name" {
  description = "Resource group name"
  value       = data.azurerm_resource_group.main.name
}

output "api_container_app_name" {
  description = "API container app name"
  value       = try(module.container_apps["api"].container_app_name, "")
}

output "frontend_container_app_name" {
  description = "Frontend container app name"
  value       = try(module.container_apps["frontend"].container_app_name, "")
}
