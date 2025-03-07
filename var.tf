### `variables.tf`

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

# VM Configurations
variable "vm_configs" {
  description = "List of VM configurations"
  type = list(object({
    vm_name              = string
    location             = string
    resource_group_name  = string
    vnet_name            = string
    subnet_name          = string
    vm_size              = string
    admin_username       = string
    admin_password       = string
    os_disk_size         = number
    os_disk_type         = string
    data_disk_size       = number
    data_disk_type       = string
  }))
}

# Default Values Example (Update this in terraform.tfvars or manually in .tf files)
variable "default_vm_configs" {
  default = [
    {
      vm_name             = "app-vm1"
      location            = "Central India"
      resource_group_name = "rg-vm1"
      vnet_name           = "vnet-vm1"
      subnet_name         = "subnet-vm1"
      vm_size             = "Standard_D16as_v5"
      admin_username      = "azureuser1"
      admin_password      = "Pass@1234"
      os_disk_size        = 128
      os_disk_type        = "Standard_LRS"
      data_disk_size      = 128
      data_disk_type      = "Standard_LRS"
    },
    {
      vm_name             = "app-vm2"
      location            = "Central India"
      resource_group_name = "rg-vm2"
      vnet_name           = "vnet-vm2"
      subnet_name         = "subnet-vm2"
      vm_size             = "Standard_D16as_v5"
      admin_username      = "azureuser2"
      admin_password      = "Pass@5678"
      os_disk_size        = 128
      os_disk_type        = "Standard_LRS"
      data_disk_size      = 128
      data_disk_type      = "Standard_LRS"
    }
  ]
}
