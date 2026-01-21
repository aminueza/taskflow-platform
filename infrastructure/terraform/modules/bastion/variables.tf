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

variable "subnet_id" {
  description = "Subnet ID for bastion"
  type        = string
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_key" {
  description = "SSH public key for authentication"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "VM size for the bastion host"
  type        = string
  default     = "Standard_B2as_v2"
}
