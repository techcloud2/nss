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
    subnet_name          = string
    vm_size              = string
    admin_username       = string
    os_disk_type         = string
    os_disk_size         = number
  }))

  default = [
    {
      vm_name             = "linux-vm-1"
      os_type             = "linux"
      os_version          = "20_04-lts-gen2"
      location            = "East US"
      resource_group_name = "rg-linux"
      vnet_name           = "vnet-linux"
      subnet_name         = "subnet-linux"
      vm_size             = "Standard_D2s_v3"
      admin_username      = "azureuser"
      os_disk_type        = "Standard_LRS"
      os_disk_size        = 30
    },
    {
      vm_name             = "windows-vm-1"
      os_type             = "windows"
      os_version          = "2019-Datacenter-smalldisk"
      location            = "East US"
      resource_group_name = "rg-windows"
      vnet_name           = "vnet-windows"
      subnet_name         = "subnet-windows"
      vm_size             = "Standard_D4s_v3"
      admin_username      = "adminuser"
      os_disk_type        = "StandardSSD_LRS"
      os_disk_size        = 127
    }
  ]
}
