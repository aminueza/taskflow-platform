variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

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

variable "subnet_id" {
  description = "Subnet ID for Container Apps environment"
  type        = string
}
