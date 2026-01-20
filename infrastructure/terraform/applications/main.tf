##########################################################
#                        Globals                         #
##########################################################
module "globals" {
  source = "../modules/globals"

  business_impact     = var.business_impact
  data_classification = var.data_classification
  location            = var.location
  environment         = var.environment
}

locals {
  base_tags = module.globals.global_config
  project_tags = merge(
    local.base_tags,
    {
      application_name = var.application_name
    }
  )

  resource_group_name        = "rg-${var.application_name}-${var.environment}-${module.globals.global_config.location_acronym}"
  container_environment_name = "cae-${var.application_name}-${var.environment}-${module.globals.global_config.location_acronym}"
}

##########################################################
#                   DATA SOURCES                         #
##########################################################
data "azurerm_resource_group" "main" {
  name = local.resource_group_name
}

data "azurerm_container_app_environment" "main" {
  name                = local.container_environment_name
  resource_group_name = data.azurerm_resource_group.main.name
}

##########################################################
#                   CONTAINER APPS                       #
##########################################################

module "container_apps" {
  for_each = var.container_apps

  source = "../modules/container_app"

  resource_group_name          = data.azurerm_resource_group.main.name
  container_app_environment_id = data.azurerm_container_app_environment.main.id

  global_config = merge(
    local.base_tags,
    {
      application_name = each.key
    }
  )

  app_name       = each.key
  container_name = each.value.container_name
  image          = each.value.image
  cpu            = each.value.cpu
  memory         = each.value.memory

  env_vars = each.value.env_vars

  secrets = try(each.value.secrets, {})

  ingress_enabled          = try(each.value.ingress_enabled, true)
  ingress_external_enabled = try(each.value.ingress_external_enabled, true)
  ingress_target_port      = try(each.value.ingress_target_port, 80)

  min_replicas = try(each.value.min_replicas, 1)
  max_replicas = try(each.value.max_replicas, 3)

  revision_mode = try(each.value.revision_mode, "Single")
}
