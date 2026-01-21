##########################################################
#                   BASTION MODULE                       #
#                   Simple Linux VM with Puppet          #
#                   Private IP Only - Access via Azure Bastion
##########################################################

resource "azurerm_network_interface" "bastion" {
  name                = module.nic_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.global_config.all_tags
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = module.vm_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.bastion.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    echo "Starting bastion host initialization..."

    # Update system
    apt-get update
    apt-get upgrade -y

    # Install Puppet 8.x
    wget https://apt.puppet.com/puppet8-release-noble.deb
    dpkg -i puppet8-release-noble.deb
    apt-get update
    apt-get install -y puppet-agent

    # Add Puppet to PATH
    echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /etc/profile.d/puppet.sh

    # Install Docker (latest stable)
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker ${var.admin_username}

    # Install Docker Compose v2
    apt-get install -y docker-compose-plugin

    # Install useful tools
    apt-get install -y git curl wget vim htop net-tools

    # Create marker file
    echo "Bastion host initialized successfully at $(date)" > /tmp/init-complete
    echo "Puppet version: $(puppet --version)" >> /tmp/init-complete
    echo "Docker version: $(docker --version)" >> /tmp/init-complete
    echo "Docker Compose version: $(docker compose version)" >> /tmp/init-complete

    echo "Initialization complete!"
  EOF
  )

  tags = var.global_config.all_tags
}
