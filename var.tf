# Azure Authentication Variables
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
  type = list(object({
    vm_name              = string
    os_type              = string
    os_version           = string
    location             = string
    resource_group_name  = string
    vnet_name            = string
    create_vnet          = bool
    vnet_address_space   = string
    subnet_name          = string
    create_subnet        = bool
    subnet_address_prefix = string
    vm_size              = string
    admin_username       = string
    os_disk_type         = string
    os_disk_size         = number
  }))

  default = [
    {
      vm_name              = "linux-vm-1"
      os_type              = "linux"
      os_version           = "20_04-lts-gen2"
      location             = "Central India"
      resource_group_name  = "rg-x"
      vnet_name            = "vnet-linux"
      create_vnet          = true
      vnet_address_space   = "10.0.0.0/16"
      subnet_name          = "subnet-linux"
      create_subnet        = true
      subnet_address_prefix = "10.0.1.0/24"
      vm_size              = "Standard_B1s"
      admin_username       = "azureuser"
      os_disk_type         = "Standard_LRS"
      os_disk_size         = 32
    },
    {
      vm_name              = "windows-vm-1"
      os_type              = "windows"
      os_version           = "2019-Datacenter-smalldisk"
      location             = "Central India"
      resource_group_name  = "rg-x"
      vnet_name            = "vnet-linux"
      create_vnet          = false
      vnet_address_space   = "10.0.0.0/16"
      subnet_name          = "subnet-linux"
      create_subnet        = false
      subnet_address_prefix = "10.0.1.0/24"
      vm_size              = "Standard_B1s"
      admin_username       = "adminuser"
      os_disk_type         = "Standard_LRS"
      os_disk_size         = 128
    }
  ]
}
