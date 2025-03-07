resource "azurerm_resource_group" "rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm if vm.create_rg }

  name     = each.value.resource_group_name
  location = each.value.location

  lifecycle {
    prevent_destroy = true
  }
}

# Conditionally create a new Virtual Network or fetch an existing one
resource "azurerm_virtual_network" "new_vnet" {
  for_each = { for vm in var.vm_configs : vm.vnet_name => vm if vm.create_vnet }

  name                = each.value.vnet_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = [each.value.vnet_address_space] # FIXED: Wrap in []

  lifecycle {
    prevent_destroy = true
  }
}

data "azurerm_virtual_network" "existing_vnet" {
  for_each = { for vm in var.vm_configs : vm.vnet_name => vm if !vm.create_vnet }

  name                = each.value.vnet_name
  resource_group_name = each.value.resource_group_name
  depends_on          = [azurerm_virtual_network.new_vnet] # FIXED: Ensure new VNet is created before fetching existing one
}

# Conditionally create a new Subnet or fetch an existing one
resource "azurerm_subnet" "new_subnet" {
  for_each = { for vm in var.vm_configs : vm.subnet_name => vm if vm.create_subnet }

  name                 = each.value.subnet_name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = azurerm_virtual_network.new_vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.subnet_address_prefixes] # FIXED: Ensure list format
}

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
    subnet_id                     = lookup(merge(
      { for subnet in azurerm_subnet.new_subnet : subnet.name => subnet.id },
      { for subnet in data.azurerm_subnet.existing_subnet : subnet.name => subnet.id }
    ), each.value.subnet_name, null)
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

  lifecycle {
    prevent_destroy = true
  }
}

# Managed Data Disks
resource "azurerm_managed_disk" "data_disk" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if lookup(vm, "data_disks", []) != [] }

  name                 = "${each.value.vm_name}-datadisk"
  location             = each.value.location
  resource_group_name  = each.value.resource_group_name
  storage_account_type = each.value.os_disk_type
  create_option        = "Empty"
  disk_size_gb         = each.value.os_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if lookup(vm, "data_disks", []) != [] }

  managed_disk_id    = azurerm_managed_disk.data_disk[each.value.vm_name].id
  virtual_machine_id = lookup(merge(
    { for vm in azurerm_linux_virtual_machine.vm : vm.name => vm.id },
    { for vm in azurerm_windows_virtual_machine.vm : vm.name => vm.id }
  ), each.value.vm_name, null)

  lun     = 0
  caching = "ReadWrite"
}
