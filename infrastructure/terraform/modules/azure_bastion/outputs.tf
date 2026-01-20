##########################################################
#               AZURE BASTION OUTPUTS                    #
##########################################################

output "bastion_id" {
  description = "Azure Bastion ID"
  value       = azurerm_bastion_host.main.id
}

output "bastion_name" {
  description = "Azure Bastion name"
  value       = azurerm_bastion_host.main.name
}

output "bastion_dns_name" {
  description = "Azure Bastion DNS name"
  value       = azurerm_bastion_host.main.dns_name
}
