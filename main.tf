resource "azurerm_resource_group" "rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm if vm.create_rg }

  name     = each.value.resource_group_name
  location = each.value.location

  lifecycle {
    prevent_destroy = true
  }
}

# Fetch existing VNet
data "azurerm_virtual_network" "existing_vnet" {
  for_each = { for vm in var.vm_configs : vm.vnet_name => vm if !vm.create_vnet }

  name                = each.value.vnet_name
  resource_group_name = each.value.resource_group_name
}

# Fetch existing subnet
data "azurerm_subnet" "existing_subnet" {
  for_each = { for vm in var.vm_configs : vm.subnet_name => vm if !vm.create_subnet }

  name                 = each.value.subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet[each.value.vnet_name].name
  resource_group_name  = each.value.resource_group_name
}

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

resource "azurerm_network_interface" "nic" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  name                = "${each.value.vm_name}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet[each.value.subnet_name].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.os_type == "Linux" }

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

  # Optional Data Disks
  dynamic "data_disk" {
    for_each = lookup(each.value, "data_disks", [])
    content {
      name                 = "${each.value.vm_name}-datadisk-${data_disk.key}"
      disk_size_gb         = data_disk.value.disk_size_gb
      storage_account_type = data_disk.value.storage_account_type
      caching              = "ReadWrite"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.os_type == "Windows" }

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

  # Optional Data Disks
  dynamic "data_disk" {
    for_each = lookup(each.value, "data_disks", [])
    content {
      name                 = "${each.value.vm_name}-datadisk-${data_disk.key}"
      disk_size_gb         = data_disk.value.disk_size_gb
      storage_account_type = data_disk.value.storage_account_type
      caching              = "ReadWrite"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
