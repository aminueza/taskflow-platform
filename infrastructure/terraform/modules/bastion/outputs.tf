output "vm_id" {
  description = "Bastion VM ID"
  value       = azurerm_linux_virtual_machine.bastion.id
}

output "vm_name" {
  description = "Bastion VM name"
  value       = azurerm_linux_virtual_machine.bastion.name
}

output "private_ip" {
  description = "Bastion private IP address (access via Azure Bastion)"
  value       = azurerm_network_interface.bastion.private_ip_address
}

output "admin_username" {
  description = "Admin username"
  value       = azurerm_linux_virtual_machine.bastion.admin_username
}
