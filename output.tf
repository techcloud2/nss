### `outputs.tf`
output "vm_public_ip" {
  value = { for idx, vm in azurerm_linux_virtual_machine.vm : idx => vm.public_ip_address }
}
