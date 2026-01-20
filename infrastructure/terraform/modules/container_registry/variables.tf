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

variable "sku" {
  description = "SKU tier (Basic, Standard, or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be 'Basic', 'Standard', or 'Premium'."
  }
}

variable "admin_enabled" {
  description = "Enable admin user (needed for docker login with username/password)"
  type        = bool
  default     = true
}
