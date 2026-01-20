##########################################################
#                     Global Variables                   #
##########################################################

variable "global_config" {
  description = "Global configuration map"
  type = object({
    location         = string
    environment      = string
    full_environment = string
    application_name = string
    location_acronym = string
    predefined_tags  = map(string)
    all_tags         = map(string)
  })

  nullable = false
}

##########################################################
#                     Custom Variables                   #
##########################################################

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "app_subnet_id" {
  description = "Application subnet ID for Key Vault network ACL"
  type        = string
}

variable "bastion_subnet_id" {
  description = "Bastion subnet ID for Key Vault network ACL"
  type        = string
}
