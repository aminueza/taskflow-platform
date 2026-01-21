##########################################################
#                   KEY VAULT MODULE                     #
#                   Secure secrets storage               #
##########################################################

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = module.kv_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [var.app_subnet_id, var.bastion_subnet_id]
    ip_rules                   = var.ip_rules
  }

  tags = var.global_config.all_tags
}

resource "tls_private_key" "bastion_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "bastion_ssh_private" {
  name         = "bastion-ssh-private-key"
  value        = tls_private_key.bastion_ssh.private_key_openssh
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.terraform_secrets_officer]
}

resource "azurerm_key_vault_secret" "bastion_ssh_public" {
  name         = "bastion-ssh-public-key"
  value        = tls_private_key.bastion_ssh.public_key_openssh
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.terraform_secrets_officer]
}

resource "random_string" "db_username" {
  length  = 12
  special = false
  upper   = false
  numeric = true
  lower   = true
}

locals {
  db_username = "admin${random_string.db_username.result}"
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "postgresql-admin-username"
  value        = local.db_username
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.terraform_secrets_officer]
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "postgresql-admin-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.terraform_secrets_officer]
}

resource "azurerm_role_assignment" "terraform_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
