provider "azurerm" {
  features {}
}

# Resource Group: prod-rg
resource "azurerm_resource_group" "prod_rg" {
  name     = "prod-rg"
  location = var.location
}

# Resource Group: vnet-rg
resource "azurerm_resource_group" "vnet_rg" {
  name     = "vnet-rg"
  location = var.location
}

# VNet: prod-vnet
resource "azurerm_virtual_network" "prod_vnet" {
  name                = "prod-vnet"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  address_space       = ["10.1.0.0/16"]
}

# Subnet: server-subnet in prod-vnet
resource "azurerm_subnet" "server_subnet" {
  name                 = "server-subnet"
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# VNet: spoke-vnet
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "spoke-vnet"
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = ["10.2.0.0/16"]
}

# Subnet: firewall-subnet in spoke-vnet
resource "azurerm_subnet" "firewall_subnet" {
  name                 = "firewall-subnet"
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

# Subnet: application-gateway-subnet in spoke-vnet
resource "azurerm_subnet" "application_gateway_subnet" {
  name                 = "application-gateway-subnet"
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.2.2.0/24"]
}
