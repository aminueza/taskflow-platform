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

variable "delegated_subnet_id" {
  description = "Subnet ID for PostgreSQL delegation"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID for private DNS link"
  type        = string
}

variable "admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = ["webapp_production"]
}
