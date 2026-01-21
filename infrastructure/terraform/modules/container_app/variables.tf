variable "resource_group_name" {
  type = string
}

variable "global_config" {
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

variable "container_app_environment_id" {
  type = string
}

variable "app_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "image" {
  type = string
}

variable "cpu" {
  type    = number
  default = 0.5
}

variable "memory" {
  type    = string
  default = "1Gi"
}

variable "command" {
  type    = list(string)
  default = null
}

variable "args" {
  type    = list(string)
  default = null
}

variable "env_vars" {
  type = map(object({
    value       = optional(string)
    secret_name = optional(string)
  }))
  default = {}
}

variable "secrets" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "revision_mode" {
  type    = string
  default = "Single"
}

variable "ingress_enabled" {
  type    = bool
  default = true
}

variable "ingress_external_enabled" {
  type    = bool
  default = true
}

variable "ingress_target_port" {
  type    = number
  default = 80
}

variable "init_container" {
  type = object({
    name    = string
    image   = string
    cpu     = optional(number, 0.25)
    memory  = optional(string, "0.5Gi")
    command = optional(list(string))
    args    = optional(list(string))
    env_vars = optional(map(object({
      value       = optional(string)
      secret_name = optional(string)
    })), {})
  })
  default = null
}

variable "registry_server" {
  description = "Container registry server URL (e.g., myacr.azurecr.io)"
  type        = string
  default     = null
}

variable "registry_identity" {
  description = "Managed identity resource ID for ACR pull (use 'System' for system-assigned)"
  type        = string
  default     = null
}

variable "registry_username" {
  description = "Container registry username (for admin auth)"
  type        = string
  default     = null
}

variable "registry_password" {
  description = "Container registry password (for admin auth)"
  type        = string
  default     = null
  sensitive   = true
}

variable "identity_type" {
  description = "Type of managed identity (SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "List of user-assigned identity IDs"
  type        = list(string)
  default     = []
}
