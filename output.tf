### `output.tf`

output "vm_details" {
  value = { for vm in var.vm_configs : vm.vm_name => {
    public_ip = try(
      azurerm_linux_virtual_machine.linux_vm[vm.vm_name].public_ip_address,
      azurerm_windows_virtual_machine.windows_vm[vm.vm_name].public_ip_address,
      "N/A"
    )
    username  = vm.admin_username
    password  = random_password.password[vm.vm_name].result
    location  = vm.location
    resource_group = vm.resource_group_name
    os_type   = vm.os_type
    os_version = vm.os_version
  }}
  sensitive = true
}
