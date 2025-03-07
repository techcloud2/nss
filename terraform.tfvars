vm_configs = [
  {
    vm_name              = "vm1"
    os_type              = "Linux"
    os_version           = "Ubuntu20.04"
    location             = "East US"
    resource_group_name  = "rg-vm1"
    vnet_name            = "vnet-vm1"
    create_vnet          = true
    vnet_address_space   = "10.0.0.0/16"
    subnet_name          = "subnet-vm1"
    create_subnet        = true
    subnet_address_prefix = "10.0.1.0/24"
    create_rg            = true
    vm_size              = "Standard_DS1_v2"
    admin_username       = "azureuser"
    os_disk_type         = "Premium_LRS"
    os_disk_size         = 30
  },
  {
    vm_name              = "vm2"
    os_type              = "Windows"
    os_version           = "Windows2019"
    location             = "West US"
    resource_group_name  = "rg-vm2"
    vnet_name            = "vnet-vm2"
    create_vnet          = false
    vnet_address_space   = "10.1.0.0/16"
    subnet_name          = "subnet-vm2"
    create_subnet        = false
    subnet_address_prefix = "10.1.1.0/24"
    create_rg            = false
    vm_size              = "Standard_B2s"
    admin_username       = "adminuser"
    os_disk_type         = "Standard_LRS"
    os_disk_size         = 50
  }
]
