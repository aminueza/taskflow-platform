locals {
  location_acronyms = {
    "westeurope"    = "weu"
    "eastus"        = "eus"
    "eastasia"      = "eas"
    "australiaeast" = "eau"
    "swedencentral" = "sdc"
    "francecentral" = "frc"
    "global"        = "global"
  }

  location_acronym = local.location_acronyms[var.location]
}

# Define full_environment with additional mappings
locals {
  fullname_environments = {
    dev    = "development"
    stg    = "staging"
    tst    = "testing"
    prd    = "production"
    global = "global"
  }

  full_environment = local.fullname_environments[var.environment]
}

locals {
  predefined_tags = {
    "Data Classification" = var.data_classification
    "Business Impact"     = var.business_impact
    "Region"              = var.location
    "Environment"         = local.full_environment
  }

  all_tags = merge(local.predefined_tags, var.tags)
}

locals {
  global_config = {
    location         = var.location
    environment      = var.environment
    full_environment = local.full_environment
    location_acronym = local.location_acronym
    predefined_tags  = local.predefined_tags
    all_tags         = local.all_tags
  }
}