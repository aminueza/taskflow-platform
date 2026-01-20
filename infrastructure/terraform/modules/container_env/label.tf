##########################################################
#                   CONTAINER ENV MODULE                 #
#                   Label Definitions                    #
##########################################################

# Label for Log Analytics Workspace
module "log_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "log"
  stage       = var.global_config.environment
  name        = var.global_config.application_name
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}

# Label for Container Apps Environment
module "cae_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "cae"
  stage       = var.global_config.environment
  name        = var.global_config.application_name
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}
