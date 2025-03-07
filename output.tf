### outputs.tf
output "vm_public_ips" {
  value = { for vm in azurerm_linux_virtual_machine.vm : vm.name => vm.public_ip_address }
}
