output "public_ips" {
  description = "Public IPs of all VMs"
  value       = { for vm_name, ip in azurerm_public_ip.public_ip : vm_name => ip.ip_address }
}

output "vm_ids" {
  description = "IDs of all VMs"
  value       = { for vm_name, vm in azurerm_linux_virtual_machine.vm : vm_name => vm.id }
}
