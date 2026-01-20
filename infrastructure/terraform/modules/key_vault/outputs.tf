##########################################################
#                   KEY VAULT OUTPUTS                    #
##########################################################

output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

# SSH Keys
output "bastion_ssh_public_key" {
  description = "Auto-generated SSH public key for bastion"
  value       = tls_private_key.bastion_ssh.public_key_openssh
  sensitive   = true
}

output "bastion_ssh_private_key" {
  description = "Auto-generated SSH private key for bastion"
  value       = tls_private_key.bastion_ssh.private_key_openssh
  sensitive   = true
}

# Database Credentials
output "db_admin_username" {
  description = "Auto-generated PostgreSQL admin username"
  value       = local.db_username
  sensitive   = true
}

output "db_admin_password" {
  description = "Auto-generated PostgreSQL admin password"
  value       = random_password.db_password.result
  sensitive   = true
}
