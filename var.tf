variable "client_id" {
  description = "The client ID of the Azure service principal"
  type        = string
}

variable "client_secret" {
  description = "The client secret of the Azure service principal"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID of the Azure subscription"
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID of the Azure subscription"
  type        = string
}

variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    vm_name              = string
    os_type              = string
    os_version           = string
    location             = string
    resource_group_name  = string
    create_rg            = optional(bool, false)
    vnet_name            = string
    create_vnet          = optional(bool, false)
    vnet_address_space   = optional(string)
    subnet_name          = string
    create_subnet        = optional(bool, false)
    subnet_address_prefix = optional(string, "10.0.1.0/24")
    vm_size              = string
    admin_username       = string
    generate_password    = optional(bool, false)
    os_disk_type         = string
    os_disk_size         = number
    create_public_ip     = optional(bool, false)
    create_data_disks    = bool  
    data_disks = optional(list(object({
      name      = string
      size_gb   = number
      disk_type = string
    })), [])
    
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
