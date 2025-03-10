vm_configs = [
  {
    vm_name              = "app-vm"
    os_type              = "Linux"
    os_version           = "22.04"
    location             = "Central India"
    resource_group_name  = "ttms-rg"
    create_rg           = false
    vnet_name            = "ttms-vnet"
    create_vnet         = true
    vnet_address_space   = "10.0.0.0/16"
    subnet_name          = "app-subnet"
    create_subnet       = true
    subnet_address_prefix = "10.0.1.0/24"
    vm_size              = "Standard_B4ms"
    admin_username       = "azureuser"
    generate_password    = "true"
    os_disk_type         = "Standard_LRS"
    os_disk_size         = 30
    create_data_disk     = true
    data_disk_type       = "Standard_LRS"
    data_disk_size       = 30
    create_data_disk     = true
    data_disk_type       = "Standard_LRS"
    data_disk_size       = 30
    create_public_ip     = true

    security_rules = [
      {
        name                       = "AllowSSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22,443,5432"
        source_address_prefix      = "1.22.26.90"
        destination_address_prefix = "*"
      }
    ]

    os_image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }

    # Optional Tags
    tags = {
      environment = "dev"
      owner       = "team-1"
    }
  }
]
