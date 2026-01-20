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
