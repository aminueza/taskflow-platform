resource "azurerm_container_app" "main" {
  name                         = module.ca_label.id
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode

  identity {
    type         = var.identity_type
    identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : null
  }

  dynamic "registry" {
    for_each = var.registry_server != null ? [1] : []
    content {
      server               = var.registry_server
      identity             = var.registry_identity
      username             = var.registry_username
      password_secret_name = var.registry_password != null ? "registry-password" : null
    }
  }

  template {
    dynamic "init_container" {
      for_each = var.init_container != null ? [var.init_container] : []
      content {
        name    = init_container.value.name
        image   = init_container.value.image
        cpu     = init_container.value.cpu
        memory  = init_container.value.memory
        command = init_container.value.command
        args    = init_container.value.args

        dynamic "env" {
          for_each = init_container.value.env_vars
          content {
            name        = env.key
            value       = env.value.value
            secret_name = lookup(env.value, "secret_name", null)
          }
        }
      }
    }

    container {
      name    = var.container_name
      image   = var.image
      cpu     = var.cpu
      memory  = var.memory
      command = var.command
      args    = var.args

      dynamic "env" {
        for_each = var.env_vars
        content {
          name        = env.key
          value       = env.value.value
          secret_name = lookup(env.value, "secret_name", null)
        }
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }

  dynamic "ingress" {
    for_each = var.ingress_enabled ? [1] : []
    content {
      external_enabled = var.ingress_external_enabled
      target_port      = var.ingress_target_port

      traffic_weight {
        latest_revision = true
        percentage      = 100
      }
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name  = secret.key
      value = secret.value
    }
  }

  # Add registry password as secret if using admin auth
  dynamic "secret" {
    for_each = var.registry_password != null ? [1] : []
    content {
      name  = "registry-password"
      value = var.registry_password
    }
  }

  tags = var.global_config.all_tags
}
