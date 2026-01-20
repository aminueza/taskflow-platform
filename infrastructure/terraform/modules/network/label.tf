##########################################################
#                   NETWORK MODULE                       #
#                   Label Definitions                    #
##########################################################

# Label for VNet
module "vnet_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "vnet"
  stage       = var.global_config.environment
  name        = var.global_config.application_name
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}

# Label for NSG
module "nsg_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "nsg"
  stage       = var.global_config.environment
  name        = "bastion-${var.global_config.application_name}"
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}

# Label for Subnets
module "subnet_labels" {
  for_each = var.subnet_configs

  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "snet"
  stage       = var.global_config.environment
  name        = "${each.key}-${var.global_config.application_name}"
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}
