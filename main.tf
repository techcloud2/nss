resource "azurerm_network_security_group" "nsg" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }
  name                = "${each.value.vm_name}-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if lower(vm.os_type) == "linux" }
  name                  = each.value.vm_name
  location              = each.value.location
  resource_group_name   = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic[each.value.vm_name].id]
  size                  = each.value.vm_size

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
    disk_size_gb         = each.value.os_disk_size
  }

  source_image_reference {
    publisher = each.value.os_image.publisher
    offer     = each.value.os_image.offer
    sku       = each.value.os_image.sku
    version   = each.value.os_image.version
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if lower(vm.os_type) == "windows" }
  name                  = each.value.vm_name
  location              = each.value.location
  resource_group_name   = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic[each.value.vm_name].id]
  size                  = each.value.vm_size

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
    disk_size_gb         = each.value.os_disk_size
  }

  source_image_reference {
    publisher = each.value.os_image.publisher
    offer     = each.value.os_image.offer
    sku       = each.value.os_image.sku
    version   = each.value.os_image.version
  }
}
