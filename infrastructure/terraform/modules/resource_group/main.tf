##########################################################
#                   RESOURCE GROUP MODULE                #
#                   Azure Resource Group                 #
##########################################################

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = module.rg_label.id
  location = var.global_config.location
  tags     = var.global_config.all_tags
}
