variable "location" {
  description = "The Azure locations"
  type        = string

  validation {
    condition     = contains(["westeurope", "eastus", "eastasia", "australiaeast", "swedencentral", "francecentral", "global"], var.location)
    error_message = "The environment must be one of the following: westeurope, eastus, eastasia, australiaeast, swedencentral, francecentral, global."
  }
}

variable "environment" {
  description = "Environment, e.g. `prd`, `stg`, `dev`, `global` or `tst`. Third item in naming sequence."
  type        = string
  default     = "stg"

  validation {
    condition     = contains(["prd", "stg", "dev", "global", "tst"], var.environment)
    error_message = "The environment must be one of the following: prd, stg, dev, tst."
  }
}

variable "application_name" {
  description = "Name, which could be the name of your solution or app. Second item in naming sequence."
  default     = "app"
  type        = string
}

######################################################
#                        Tags                        #
######################################################

variable "data_classification" {
  type        = string
  default     = "Confidential"
  description = "Sensitivity of data that the resources host"

  validation {
    condition     = contains(["Confidential", "Internal", "Public"], var.data_classification)
    error_message = "The data_classification must be one of the following: Confidential, Internal, Public."
  }
}

variable "business_impact" {
  type        = string
  default     = "Medium"
  description = "Business impact of the resource in case of outage."

  validation {
    condition     = contains(["Low", "Medium", "High"], var.business_impact)
    error_message = "The business_impact must be one of the following: Low, Medium, High."
  }
}

variable "tags" {
  description = "Default tags to be applied across all resources"
  type        = map(string)
  default     = {}
}
