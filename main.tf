### `main.tf`
resource "azurerm_resource_group" "rg" {
  count = var.vm_configs[*].create_rg ? 1 : 0
  
  name     = var.vm_configs[0].resource_group_name
  location = var.vm_configs[0].location
}

resource "azurerm_virtual_network" "vnet" {
  count = var.vm_configs[*].create_vnet ? 1 : 0
  
  name                = var.vm_configs[0].vnet_name
  location            = var.vm_configs[0].location
  resource_group_name = var.vm_configs[0].resource_group_name
  address_space       = [var.vm_configs[0].vnet_address_space]
}

resource "azurerm_subnet" "subnet" {
  count = var.vm_configs[*].create_subnet ? 1 : 0
  
  name                 = var.vm_configs[0].subnet_name
  resource_group_name  = var.vm_configs[0].resource_group_name
  virtual_network_name = var.vm_configs[0].vnet_name
  address_prefixes     = [var.vm_configs[0].subnet_address_prefix]
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = { for idx, vm in var.vm_configs : idx => vm }

  name                  = each.value.vm_name
  resource_group_name   = each.value.resource_group_name
  location              = each.value.location
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

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

resource "azurerm_network_interface" "nic" {
  for_each = { for idx, vm in var.vm_configs : idx => vm }

  name                = "nic-${each.value.vm_name}"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "Dynamic"
  }
}
