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
  for_each = { for vm in var.vm_configs : "${vm.vnet_name}-${vm.resource_group_name}" => vm... if !vm.create_vnet }

name                = each.value[0].vnet_name
resource_group_name = each.value[0].resource_group_name

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
  for_each = {
    for vm in var.vm_configs :
    vm.subnet_name => vm
    if !vm.create_subnet &&
    contains(keys(data.azurerm_virtual_network.existing_vnet), vm.vnet_name)
  }

  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}



#pip
resource "azurerm_public_ip" "public_ip" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.create_public_ip }

  name                = "${each.value.vm_name}-public-ip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" # Standard supports zone redundancy

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

    # ✅ Attach Public IP if 'create_public_ip' is true
    public_ip_address_id = contains(keys(azurerm_public_ip.public_ip), each.key) ? azurerm_public_ip.public_ip[each.key].id : null
  }

  depends_on = [azurerm_subnet.new_subnet, data.azurerm_subnet.existing_subnet, azurerm_public_ip.public_ip]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  name                = "${each.value.vm_name}-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  depends_on = [azurerm_resource_group.rg]
}

# Attach NSG to each VM's NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  network_interface_id      = azurerm_network_interface.nic[each.value.vm_name].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.vm_name].id
}

# Random Password Generator
resource "random_password" "vm_password" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.generate_password }

  length           = 16
  special         = true
  override_special = "!@#"
}

# Credential
resource "local_file" "vm_credentials" {
  content  = join("\n", [for vm in var.vm_configs : <<EOT
VM Name: ${vm.vm_name}
Private IP: ${lookup(azurerm_network_interface.nic[vm.vm_name].ip_configuration[0], "private_ip_address", "N/A")}
Password: ${lookup(random_password.vm_password, vm.vm_name, {}).result}
Resource Group: ${vm.resource_group_name}
Location: ${vm.location}
----------------------------
EOT
  ])
  filename = "credential.txt"
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
  admin_password = lookup(random_password.vm_password, each.key, {}).result
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

# Window Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm if vm.os_type == "Windows" }

  name                  = each.value.vm_name
  location              = each.value.location
  resource_group_name   = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic[each.value.vm_name].id]
  size                  = each.value.vm_size

  admin_username = each.value.admin_username
  admin_password = lookup(random_password.vm_password, each.key, {}).result

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

resource "azurerm_managed_disk" "data_disks" {
  for_each = { for entry in flatten([
    for vm in var.vm_configs : (
      vm.create_data_disks ? [
        for disk in vm.data_disks : {
          key      = "${vm.vm_name}-${disk.name}"
          vm_name  = vm.vm_name
          location = vm.location
          rg_name  = vm.resource_group_name
          disk_name = disk.name
          disk_size_gb = disk.size_gb
          disk_type = disk.disk_type
        }
      ] : []
    )
  ]) : entry.key => entry }

  name                 = each.value.disk_name
  location             = each.value.location
  resource_group_name  = each.value.rg_name
  storage_account_type = each.value.disk_type
  disk_size_gb         = each.value.disk_size_gb
  create_option        = "Empty"
}


resource "azurerm_virtual_machine_data_disk_attachment" "attach_disks" {
  for_each = azurerm_managed_disk.data_disks

  managed_disk_id    = each.value.id
  virtual_machine_id = lookup(merge(
    { for vm in azurerm_linux_virtual_machine.vm : vm.name => vm.id },
    { for vm in azurerm_windows_virtual_machine.vm : vm.name => vm.id }
  ), split("-", each.key)[0], null)

  lun     = index(keys(azurerm_managed_disk.data_disks), each.key)
  caching = "ReadWrite"

  depends_on = [azurerm_linux_virtual_machine.vm, azurerm_windows_virtual_machine.vm]
}
