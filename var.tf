variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    vm_name              = string
    os_type              = string
    os_version           = string
    location             = string
    resource_group_name  = string
    create_rg           = bool
    vnet_name            = string
    create_vnet         = bool
    vnet_address_space   = string
    subnet_name          = string
    create_subnet       = bool
    subnet_address_prefix = string
    vm_size              = string
    admin_username       = string
    admin_password       = string
    os_disk_type         = string
    os_disk_size         = number

    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))

    os_image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
}
