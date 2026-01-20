##########################################################
#             AZURE CONTAINER REGISTRY MODULE            #
#        Private Docker image registry for CI/CD         #
##########################################################

resource "azurerm_container_registry" "main" {
  name                = module.acr_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  tags = var.global_config.all_tags
}
