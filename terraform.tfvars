vm_configs = [
  {
    vm_name              = "app-vm-1"
    os_type              = "Linux"
    os_version           = "22.04"
    location             = "Central India"
    resource_group_name  = "ttms-rg-1"
    vnet_name            = "ttms-vnet-1"
    create_vnet          = true
    vnet_address_space   = "10.0.0.0/16"
    subnet_name          = "app-subnet-1"
    create_subnet        = true
    subnet_address_prefix = "10.0.1.0/24"
    create_rg            = true
    vm_size              = "Standard_D16as_v5"
    admin_username       = "azureuser"
    admin_password       = "YourPassword1"   # Make sure this field is present
    os_disk_type         = "StandardSSD_LRS"
    os_disk_size         = 128
  },
  {
    vm_name              = "app-vm-2"
    os_type              = "Linux"
    os_version           = "22.04"
    location             = "Central India"
    resource_group_name  = "ttms-rg-2"
    vnet_name            = "ttms-vnet-2"
    create_vnet          = true
    vnet_address_space   = "10.1.0.0/16"
    subnet_name          = "app-subnet-2"
    create_subnet        = true
    subnet_address_prefix = "10.1.1.0/24"
    create_rg            = true
    vm_size              = "Standard_D16as_v5"
    admin_username       = "azureuser"
    admin_password       = "YourPassword2"   # Make sure this field is present
    os_disk_type         = "StandardSSD_LRS"
    os_disk_size         = 128
  }
]
