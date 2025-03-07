### main.tf
resource "azurerm_resource_group" "rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm if vm.create_rg }
  name     = each.key
  location = each.value.location
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = { for vm in var.vm_configs : vm.vnet_name => vm if vm.create_vnet }
  name               = each.key
  address_space      = [each.value.vnet_address_space]
  location          = each.value.location
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  for_each = { for vm in var.vm_configs : vm.subnet_name => vm if vm.create_subnet }
  name                 = each.key
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = [each.value.subnet_address_prefix]
}

resource "azurerm_network_interface" "nic" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }
  name                = "${each.value.vm_name}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.subnet_name].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = { for vm in var.vm_configs : vm.vm_name => vm if vm.os_type == "linux" }
  name                = each.value.vm_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.vm_size
  admin_username      = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.value.vm_name].id]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
    disk_size_gb         = each.value.os_disk_size
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = each.value.os_version
    version   = "latest"
  }
}
