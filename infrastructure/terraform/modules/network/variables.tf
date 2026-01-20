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


variable "vnet_address_space" {
  description = "VNet address space"
  type        = string
}

variable "subnet_configs" {
  description = "Subnet configurations"
  type = map(object({
    address_prefix                    = string
    service_endpoints                 = list(string)
    delegation                        = optional(string)
    private_endpoint_network_policies = optional(string)
  }))
}
