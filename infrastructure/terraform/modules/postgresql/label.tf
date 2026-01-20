##########################################################
#                   POSTGRESQL MODULE                    #
#                   Label Definitions                    #
##########################################################

# Label for PostgreSQL Server
module "psql_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "psql"
  stage       = var.global_config.environment
  name        = var.global_config.application_name
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}

# Label for Private DNS Zone
module "pdns_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "pdns"
  stage       = var.global_config.environment
  name        = "postgres-${var.global_config.application_name}"
  attributes  = [var.global_config.location_acronym]
  delimiter   = "-"
  label_order = ["namespace", "name", "stage", "attributes"]

  tags = var.global_config.all_tags
}
