### ✅ Check if the Resource Group Already Exists
data "azurerm_resource_group" "existing_rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm }

  name = each.value.resource_group_name
}

### ✅ Create Resource Group Only If It Does NOT Exist
resource "azurerm_resource_group" "rg" {
  for_each = { for vm in var.vm_configs : vm.resource_group_name => vm if vm.create_rg && !contains(keys(data.azurerm_resource_group.existing_rg), vm.resource_group_name) }

  name     = each.value.resource_group_name
  location = each.value.location
}

### ✅ Check if VNet Already Exists
data "azurerm_virtual_network" "existing_vnet" {
  for_each = { for vm in var.vm_configs : vm.vnet_name => vm }
  
  name                = each.value.vnet_name
  resource_group_name = each.value.resource_group_name
}

### ✅ Create VNet Only If It Does NOT Exist
resource "azurerm_virtual_network" "vnet" {
  for_each = { for vm in var.vm_configs : vm.vnet_name => vm if vm.create_vnet && !contains(keys(data.azurerm_virtual_network.existing_vnet), vm.vnet_name) }
  
  name                = each.value.vnet_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = [each.value.vnet_address_space]
}

### ✅ Check if Subnet Already Exists
data "azurerm_subnet" "existing_subnet" {
  for_each = { for vm in var.vm_configs : vm.subnet_name => vm }

  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

### ✅ Create Subnet Only If It Does NOT Exist
resource "azurerm_subnet" "subnet" {
  for_each = { for vm in var.vm_configs : vm.subnet_name => vm if vm.create_subnet && !contains(keys(data.azurerm_subnet.existing_subnet), vm.subnet_name) }
  
  name                 = each.value.subnet_name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = [each.value.subnet_address_prefix]
  depends_on           = [azurerm_virtual_network.vnet]
}

### ✅ Ensure Public IP, NSG, and NIC Do Not Recreate Unnecessarily
resource "azurerm_public_ip" "public_ip" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  name                = "${each.value.vm_name}-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  name                = "${each.value.vm_name}-nsg"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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
    public_ip_address_id          = azurerm_public_ip.public_ip[each.value.vm_name].id
  }
}

### ✅ Create VM Without Destroying Resources
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  name                = each.value.vm_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic[each.value.vm_name].id]
  size                = each.value.vm_size

  admin_username = each.value.admin_username
  admin_password = each.value.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
    disk_size_gb         = each.value.os_disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

### ✅ Attach Data Disk to VM Without Destroying
resource "azurerm_managed_disk" "data_disk" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  name                 = "${each.value.vm_name}-datadisk"
  location             = each.value.location
  resource_group_name  = each.value.resource_group_name
  storage_account_type = each.value.os_disk_type
  create_option        = "Empty"
  disk_size_gb         = each.value.os_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  for_each = { for vm in var.vm_configs : vm.vm_name => vm }

  managed_disk_id    = azurerm_managed_disk.data_disk[each.value.vm_name].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.value.vm_name].id
  lun               = 0
  caching           = "ReadWrite"
}
