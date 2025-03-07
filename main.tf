### `main.tf`

resource "random_password" "password" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }
  length           = 16
  special          = true
  override_special = "!@#"
}

resource "azurerm_resource_group" "rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm if lookup(vm, "create_rg", false) }
  
  name     = each.value.resource_group_name
  location = each.value.location
}

resource "azurerm_virtual_network" "vnet" {
  for_each = { for vm in var.vm_configs : "${vm.resource_group_name}-${vm.vnet_name}" => vm if lookup(vm, "create_vnet", false) }
  
  name                = each.value.vnet_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = [each.value.vnet_address_space]
}

resource "azurerm_subnet" "subnet" {
  for_each = { for vm in var.vm_configs : "${vm.resource_group_name}-${vm.subnet_name}" => vm if lookup(vm, "create_subnet", false) }
  
  name                 = each.value.subnet_name
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
    subnet_id                     = azurerm_subnet.subnet["${each.value.resource_group_name}-${each.value.subnet_name}"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.os_type == "linux" }
  
  name                  = each.value.vm_name
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  admin_password        = random_password.password[each.value.vm_name].result
  disable_password_authentication = false
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

resource "azurerm_windows_virtual_machine" "windows_vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.os_type == "windows" }
  
  name                  = each.value.vm_name
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  admin_password        = random_password.password[each.value.vm_name].result
  network_interface_ids = [azurerm_network_interface.nic[each.value.vm_name].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
    disk_size_gb         = each.value.os_disk_size
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = each.value.os_version
    version   = "latest"
  }
}
