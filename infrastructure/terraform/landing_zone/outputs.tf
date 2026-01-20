##########################################################
#                   RESOURCE GROUP OUTPUTS               #
##########################################################

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_group_id
}

##########################################################
#                   NETWORK OUTPUTS                      #
##########################################################

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.network.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = module.network.subnet_ids
}

##########################################################
#                   KEY VAULT OUTPUTS                    #
##########################################################

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.key_vault_uri
}

output "bastion_ssh_private_key" {
  description = "Auto-generated SSH private key for bastion access (retrieve from Key Vault)"
  value       = module.key_vault.bastion_ssh_private_key
  sensitive   = true
}

output "db_admin_username" {
  description = "Auto-generated PostgreSQL admin username (stored in Key Vault)"
  value       = module.key_vault.db_admin_username
  sensitive   = true
}

output "db_admin_password" {
  description = "Auto-generated PostgreSQL admin password (stored in Key Vault)"
  value       = module.key_vault.db_admin_password
  sensitive   = true
}

##########################################################
#                   CONTAINER REGISTRY OUTPUTS           #
##########################################################

output "acr_login_server" {
  description = "ACR login server URL"
  value       = module.container_registry.login_server
}

output "acr_name" {
  description = "ACR name"
  value       = module.container_registry.registry_name
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = module.container_registry.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = module.container_registry.admin_password
  sensitive   = true
}

##########################################################
#                   AZURE BASTION OUTPUTS                #
##########################################################

output "azure_bastion_name" {
  description = "Azure Bastion Service name (use Azure Portal to connect)"
  value       = module.azure_bastion.bastion_name
}

output "azure_bastion_dns" {
  description = "Azure Bastion DNS name"
  value       = module.azure_bastion.bastion_dns_name
}

##########################################################
#                   BASTION VM OUTPUTS                   #
##########################################################

output "bastion_vm_id" {
  description = "Bastion VM resource ID"
  value       = module.bastion.vm_id
}

output "bastion_vm_name" {
  description = "Bastion VM name (access via Azure Bastion)"
  value       = module.bastion.vm_name
}

output "bastion_private_ip" {
  description = "Bastion VM private IP (access via Azure Bastion)"
  value       = module.bastion.private_ip
}

##########################################################
#                   DATABASE OUTPUTS                     #
##########################################################

output "postgresql_server_name" {
  description = "PostgreSQL server name"
  value       = module.postgresql.server_name
}

output "postgresql_server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = module.postgresql.server_fqdn
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string"
  value       = module.postgresql.connection_string
  sensitive   = true
}

##########################################################
#                   CONTAINER ENV OUTPUTS                #
##########################################################

output "container_environment_id" {
  description = "Container App Environment ID"
  value       = module.container_env.environment_id
}

output "container_environment_name" {
  description = "Container App Environment Name"
  value       = module.container_env.environment_name
}

output "container_environment_default_domain" {
  description = "Container App Environment default domain"
  value       = module.container_env.default_domain
}

##########################################################
#                   GLOBAL CONFIG OUTPUT                 #
##########################################################

output "global_config" {
  description = "Global configuration for use by applications"
  value       = local.common_tags
}
