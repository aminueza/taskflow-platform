##########################################################
#                   RESOURCE GROUP MODULE                #
#                   Label Definitions                    #
##########################################################

# Label for Resource Group
module "rg_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "rg"
  stage       = var.global_config.environment
  name        = var.global_config.application_name
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}
