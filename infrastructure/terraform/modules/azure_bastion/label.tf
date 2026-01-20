##########################################################
#                 AZURE BASTION MODULE                   #
#                   Label Definitions                    #
##########################################################

# Label for Azure Bastion
module "bastion_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "bastion"
  stage       = var.global_config.environment
  name        = var.global_config.application_name
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}

# Label for Public IP (required for Azure Bastion Service)
module "pip_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "pip"
  stage       = var.global_config.environment
  name        = "bastion-${var.global_config.application_name}"
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}
