##########################################################
#                   POSTGRESQL MODULE                    #
#                   Azure PostgreSQL Flexible Server     #
##########################################################

data "azurerm_client_config" "current" {}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = var.global_config.all_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = module.pdns_label.id
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id

  tags = var.global_config.all_tags
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = module.psql_label.id
  location            = var.global_config.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  sku_name     = "B_Standard_B1ms"
  version      = "17"
  storage_mb   = 32768
  storage_tier = "P10"

  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  auto_grow_enabled             = true

  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]

  tags = var.global_config.all_tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each  = toset(var.databases)
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}
