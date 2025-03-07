vm_configs = [
  {
    vm_name             = "linux-vm-1"
    location            = "Central India"
    resource_group_name = "rg-x"
    vnet_name           = "vnet-x"
    subnet_name         = "subnet-linux"
    vm_size             = "Standard_B1s"
    admin_username      = "azureuser"
    os_disk_size        = 32
    os_disk_type        = "Standard_LRS"
    os_type             = "linux"
    os_version          = "20_04-lts"
  },
  {
    vm_name             = "windows-vm-1"
    location            = "Central India"
    resource_group_name = "rg-x"
    vnet_name           = "vnet-x"
    subnet_name         = "subnet-windows"
    vm_size             = "Standard_B1s"
    admin_username      = "winadmin"
    os_disk_size        = 128
    os_disk_type        = "Standard_LRS"
    os_type             = "windows"
    os_version          = "2019-Datacenter"
  }
]
