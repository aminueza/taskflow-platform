environment      = "global"
application_name = "taskflow"
location         = "francecentral"

vnet_address_space = "10.0.0.0/16"

bastion_admin_username = "azureuser"
ip_rules = ["62.163.78.87/32"]
databases = ["webapp_production"]
