vm_configs = [
  {
    vm_name              = "app-vm-1"
    os_type              = "Linux"
    os_version           = "22.04"
    location             = "Central India"
    resource_group_name  = "ttms-rg-1"
    create_rg           = true
    vnet_name            = "ttms-vnet-1"
    create_vnet         = true
    vnet_address_space   = "10.0.0.0/16"
    subnet_name          = "app-subnet-1"
    create_subnet       = true
    subnet_address_prefix = "10.0.1.0/24"
    vm_size              = "Standard_B1s"
    admin_username       = "azureuser"
    admin_password       = "YourPassword1"
    os_disk_type         = "Standard_LRS"
    os_disk_size         = 32

    security_rules = [
      {
        name                       = "AllowSSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]

    os_image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }

    # Optional Data Disks
    data_disks = [
      {
        disk_size_gb         = 64
        storage_account_type = "StandardSSD_LRS"
      }
    ]

    # Optional Tags
    tags = {
      environment = "dev"
      owner       = "team-1"
    }
  },
  {
    vm_name              = "app-vm-2"
    os_type              = "Windows"
    os_version           = "2019"
    location             = "Central India"
    resource_group_name  = "ttms-rg-1"
    create_rg           = false
    vnet_name            = "ttms-vnet-1"
    create_vnet         = false
    subnet_name          = "app-subnet-2"
    create_subnet       = true
    subnet_address_prefix = "10.0.0.0/24"
    vm_size              = "Standard_B1s"
    admin_username       = "azureuser"
    admin_password       = "YourPassword2"
    os_disk_type         = "Standard_LRS"
    os_disk_size         = 128

    security_rules = [
      {
        name                       = "AllowRDP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]

    os_image = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }

    # Optional Data Disks
    data_disks = []

    # Optional Tags
    tags = {
      environment = "prod"
      owner       = "team-2"
    }
  }
]
