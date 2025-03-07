### var.tf
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
    vm_name               = string
    os_type               = string
    os_version            = string
    location              = string
    resource_group_name   = string
    vnet_name             = string
    create_vnet           = optional(bool, false)
    vnet_address_space    = string
    subnet_name           = string
    create_subnet         = optional(bool, false)
    subnet_address_prefix = string
    create_rg             = optional(bool, false)
    vm_size               = string
    admin_username        = string
    os_disk_type          = string
    os_disk_size          = number
  }))
}
