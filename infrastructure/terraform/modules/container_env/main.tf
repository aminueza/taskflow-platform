##########################################################
#                   CONTAINER ENV MODULE                 #
#                   Azure Container Apps Environment     #
##########################################################

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = module.log_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.global_config.all_tags
}

# Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                = module.cae_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id       = var.subnet_id
  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = false

  tags = var.global_config.all_tags
}
