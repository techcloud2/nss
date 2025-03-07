output "vm_public_ips" {
  description = "Public IPs of the VMs"
  value = { 
    for vm in azurerm_network_interface.nic : 
    vm.name => vm.ip_configuration[0].private_ip_address 
  }
}

output "vm_private_ips" {
  description = "Private IPs of the VMs"
  value = { 
    for vm in azurerm_network_interface.nic : 
    vm.name => vm.ip_configuration[0].private_ip_address 
  }
}

output "vm_ids" {
  description = "IDs of the VMs"
  value = merge(
    { for vm in azurerm_linux_virtual_machine.vm : vm.name => vm.id },
    { for vm in azurerm_windows_virtual_machine.vm : vm.name => vm.id }
  )
}

output "nsg_ids" {
  description = "IDs of the Network Security Groups"
  value = { for nsg in azurerm_network_security_group.nsg : nsg.name => nsg.id }
}

output "resource_group_names" {
  description = "Names of the resource groups used"
  value = distinct([for vm in var.vm_configs : vm.resource_group_name])
}
