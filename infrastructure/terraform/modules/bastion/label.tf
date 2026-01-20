##########################################################
#                   BASTION MODULE                       #
#                   Label Definitions                    #
##########################################################

# Label for Bastion VM
module "vm_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "vm"
  stage       = var.global_config.environment
  name        = "bastion-${var.global_config.application_name}"
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}

# Label for Network Interface
module "nic_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "nic"
  stage       = var.global_config.environment
  name        = "bastion-${var.global_config.application_name}"
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}
