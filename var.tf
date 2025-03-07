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
  description = "Configuration for multiple VMs"
  type = list(object({
    vm_name              = string
    location             = string
    resource_group_name  = string
    vnet_name            = string
    subnet_name          = string
    vm_size              = string
    admin_username       = string
    os_disk_size         = number
    os_disk_type         = string
    os_type              = string
    os_version           = string
  }))
}
