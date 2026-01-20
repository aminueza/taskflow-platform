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
#                   CONTAINER APPS CONFIG                #
##########################################################

variable "container_apps" {
  description = "Map of container apps to deploy"
  type = map(object({
    container_name           = string
    image                    = optional(string)
    cpu                      = number
    memory                   = string
    env_vars                 = map(object({
      value       = optional(string)
      secret_name = optional(string)
    }))
    secrets                  = optional(map(string))
    ingress_enabled          = optional(bool)
    ingress_external_enabled = optional(bool)
    ingress_target_port      = optional(number)
    min_replicas             = optional(number)
    max_replicas             = optional(number)
    revision_mode            = optional(string)
  }))
  default = {}
}
