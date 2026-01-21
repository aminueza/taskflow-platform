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
  common_tags = merge(
    module.globals.global_config,
    {
      application_name = var.application_name
    }
  )
}

##########################################################
#                   RESOURCE GROUP                       #
##########################################################
module "resource_group" {
  source = "../modules/resource_group"

  global_config = local.common_tags
}

##########################################################
#                   NETWORK                              #
##########################################################
module "network" {
  source = "../modules/network"

  resource_group_name = module.resource_group.resource_group_name
  global_config       = local.common_tags

  vnet_address_space = var.vnet_address_space
  subnet_configs     = var.subnet_configs
}

##########################################################
#                   KEY VAULT                            #
##########################################################
module "key_vault" {
  source = "../modules/key_vault"

  resource_group_name = module.resource_group.resource_group_name
  global_config       = local.common_tags
  app_subnet_id       = module.network.subnet_ids["apps"]
  bastion_subnet_id   = module.network.subnet_ids["bastion"]
  ip_rules            = var.ip_rules
}

##########################################################
#                   CONTAINER REGISTRY                   #
##########################################################
module "container_registry" {
  source = "../modules/container_registry"

  resource_group_name = module.resource_group.resource_group_name
  global_config       = local.common_tags
  sku                 = "Standard"
  admin_enabled       = true
}

##########################################################
#                   AZURE BASTION SERVICE                #
##########################################################
module "azure_bastion" {
  source = "../modules/azure_bastion"

  resource_group_name = module.resource_group.resource_group_name
  global_config       = local.common_tags
  subnet_id           = module.network.subnet_ids["AzureBastionSubnet"]
}

##########################################################
#                   BASTION HOST VM                      #
##########################################################
module "bastion" {
  source = "../modules/bastion"

  resource_group_name = module.resource_group.resource_group_name
  global_config       = local.common_tags

  subnet_id      = module.network.subnet_ids["bastion"]
  admin_username = var.bastion_admin_username
  admin_ssh_key  = module.key_vault.bastion_ssh_public_key
}

##########################################################
#                   POSTGRESQL DATABASE                  #
##########################################################
module "postgresql" {
  source = "../modules/postgresql"

  resource_group_name = module.resource_group.resource_group_name
  global_config       = local.common_tags

  delegated_subnet_id = module.network.subnet_ids["database"]
  vnet_id             = module.network.vnet_id

  admin_username = module.key_vault.db_admin_username
  admin_password = module.key_vault.db_admin_password

  databases = var.databases
}

##########################################################
#                   CONTAINER ENVIRONMENT                #
##########################################################
module "container_env" {
  source = "../modules/container_env"

  resource_group_name = module.resource_group.resource_group_name
  global_config       = local.common_tags

  subnet_id = module.network.subnet_ids["apps"]
}
