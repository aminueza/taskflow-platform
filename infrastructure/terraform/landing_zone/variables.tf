##########################################################
#                        Globals                         #
##########################################################
variable "environment" {
  description = "Environment, e.g. `prd`, `stg`, `dev`, or `tst`. Third item in naming sequence."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The location of the resources."
  type        = string
  default     = "westeurope"
}

variable "business_impact" {
  description = "The business impact of the application."
  type        = string
  default     = "Low"
}

variable "data_classification" {
  description = "The data classification of the application."
  type        = string
  default     = "Confidential"
}

variable "application_name" {
  description = "The name of the project."
  type        = string
  default     = "taskflow"
}

##########################################################
#                   NETWORK VARIABLES                    #
##########################################################

variable "vnet_address_space" {
  description = "VNet address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_configs" {
  description = "Subnet configurations"
  type = map(object({
    address_prefix                    = string
    service_endpoints                 = list(string)
    delegation                        = optional(string)
    private_endpoint_network_policies = optional(string)
  }))
  default = {
    bastion = {
      address_prefix                    = "10.0.1.0/24"
      service_endpoints                 = []
      private_endpoint_network_policies = "Disabled"
    }
    AzureBastionSubnet = {
      address_prefix                    = "10.0.5.0/26"
      service_endpoints                 = []
      private_endpoint_network_policies = "Disabled"
    }
    apps = {
      address_prefix                    = "10.0.2.0/23"
      service_endpoints                 = ["Microsoft.Sql", "Microsoft.KeyVault"]
      delegation                        = "Microsoft.App/environments"
      private_endpoint_network_policies = "Disabled"
    }
    database = {
      address_prefix                    = "10.0.4.0/24"
      service_endpoints                 = []
      delegation                        = "Microsoft.DBforPostgreSQL/flexibleServers"
      private_endpoint_network_policies = "Disabled"
    }
  }
}

##########################################################
#                   BASTION VARIABLES                    #
##########################################################

variable "bastion_admin_username" {
  description = "Bastion VM admin username"
  type        = string
  default     = "azureuser"
}

##########################################################
#                   DATABASE VARIABLES                   #
##########################################################

variable "databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = ["webapp_production"]
}
