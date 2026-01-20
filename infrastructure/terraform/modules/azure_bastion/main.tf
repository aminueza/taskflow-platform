##########################################################
#               AZURE BASTION SERVICE MODULE             #
#     Managed PaaS for secure RDP/SSH access to VMs     #
##########################################################

# Public IP for Azure Bastion Service (required)
resource "azurerm_public_ip" "bastion" {
  name                = module.pip_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.global_config.all_tags
}

# Azure Bastion Service
resource "azurerm_bastion_host" "main" {
  name                = module.bastion_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  # Standard SKU features
  tunneling_enabled       = true
  file_copy_enabled       = true
  shareable_link_enabled  = false
  ip_connect_enabled      = true

  tags = var.global_config.all_tags
}
