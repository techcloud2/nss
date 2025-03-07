# Resource Group Creation
resource "azurerm_resource_group" "rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm if vm.create_rg }

  name     = each.value.resource_group_name
  location = each.value.location

  lifecycle {
    prevent_destroy = true
  }
}

# Virtual Network Creation
resource "azurerm_virtual_network" "new_vnet" {
  for_each = { for vm in var.vm_configs : vm.vnet_name => vm if vm.create_vnet }

  name                = each.value.vnet_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = [each.value.vnet_address_space]

  depends_on = [azurerm_resource_group.rg]
}

# Fetch existing Virtual Network
data "azurerm_virtual_network" "existing_vnet" {
  for_each = { for vm in var.vm_configs : vm.vnet_name => vm if !vm.create_vnet }

  name                = each.value.vnet_name
  resource_group_name = each.value.resource_group_name

  depends_on = [azurerm_virtual_network.new_vnet]
}

# Subnet Creation
resource "azurerm_subnet" "new_subnet" {
  for_each = { for vm in var.vm_configs : vm.subnet_name => vm if vm.create_subnet }

  name                 = each.value.subnet_name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = azurerm_virtual_network.new_vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.subnet_address_prefix]

  depends_on = [azurerm_virtual_network.new_vnet]
}

# Fetch existing Subnet
data "azurerm_subnet" "existing_subnet" {
  for_each = { for vm in var.vm_configs : vm.subnet_name => vm if !vm.create_subnet }

  name                 = each.value.subnet_name
  virtual_network_name = lookup(merge(
    { for vnet in azurerm_virtual_network.new_vnet : vnet.name => vnet.name },
    { for vnet in data.azurerm_virtual_network.existing_vnet : vnet.name => vnet.name }
  ), each.value.vnet_name, null)
  resource_group_name  = each.value.resource_group_name

  depends_on = [azurerm_virtual_network.new_vnet]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  name                = "${each.value.vm_name}-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  depends_on = [azurerm_resource_group.rg]
}

# Network Interface
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

  depends_on = [azurerm_subnet.new_subnet, data.azurerm_subnet.existing_subnet]
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.os_type == "Linux" }

  name                  = each.value.vm_name
  location              = each.value.location
  resource_group_name   = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic[each.value.vm_name].id]
  size                  = each.value.vm_size

  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
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

  depends_on = [azurerm_network_interface.nic]
}

# Windows Virtual Machine
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

  depends_on = [azurerm_network_interface.nic]
}
