resource "azurerm_resource_group" "rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm... }
  
  name     = each.key
  location = each.value[0].location
}

resource "azurerm_virtual_network" "vnet" {
  for_each = { for vm in var.vm_configs : "${vm.resource_group_name}-${vm.vnet_name}" => vm... }
  
  name                = each.value[0].vnet_name
  location            = each.value[0].location
  resource_group_name = each.value[0].resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  for_each = { for vm in var.vm_configs : "${vm.resource_group_name}-${vm.vnet_name}-${vm.subnet_name}" => vm... }
  
  name                 = each.value[0].subnet_name
  resource_group_name  = each.value[0].resource_group_name
  virtual_network_name = each.value[0].vnet_name
  address_prefixes     = ["10.0.1.0/24"]
}
