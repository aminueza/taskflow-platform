##########################################################
#                   NETWORK MODULE                       #
#                   Single VNet with 3 Subnets           #
##########################################################

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = module.vnet_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]

  tags = var.global_config.all_tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnet_configs

  # Azure Bastion subnet MUST be named exactly "AzureBastionSubnet"
  name                 = each.key == "AzureBastionSubnet" ? "AzureBastionSubnet" : module.subnet_labels[each.key].id
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [1] : []
    content {
      name = "delegation"
      service_delegation {
        name = each.value.delegation
      }
    }
  }

  private_endpoint_network_policies = try(each.value.private_endpoint_network_policies, "Disabled")
}

resource "azurerm_network_security_group" "bastion" {
  name                = module.nsg_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name

  # Allow SSH from anywhere (in production, restrict this)
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP/HTTPS for pgAdmin
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443", "5050"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.global_config.all_tags
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.subnets["bastion"].id
  network_security_group_id = azurerm_network_security_group.bastion.id
}
