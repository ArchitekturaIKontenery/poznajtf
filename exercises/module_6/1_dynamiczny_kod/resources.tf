resource "azurerm_resource_group" "rg" {
  name     = "rg-poznaj-terraform"
  location = "westeurope"
}

resource "azurerm_storage_account" "storage" {
  name                     = "storagepoznajtf"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  dynamic "network_rules" {
    for_each = var.network_rules

    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
    }
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtnetname"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}