output "prod_rg_id" {
  description = "ID of the prod-rg resource group"
  value       = azurerm_resource_group.prod_rg.id
}

output "vnet_rg_id" {
  description = "ID of the vnet-rg resource group"
  value       = azurerm_resource_group.vnet_rg.id
}

output "prod_vnet_id" {
  description = "ID of the prod-vnet"
  value       = azurerm_virtual_network.prod_vnet.id
}

output "spoke_vnet_id" {
  description = "ID of the spoke-vnet"
  value       = azurerm_virtual_network.spoke_vnet.id
}

output "server_subnet_id" {
  description = "ID of the server subnet in prod-vnet"
  value       = azurerm_subnet.server_subnet.id
}

output "firewall_subnet_id" {
  description = "ID of the firewall subnet in spoke-vnet"
  value       = azurerm_subnet.firewall_subnet.id
}

output "application_gateway_subnet_id" {
  description = "ID of the application gateway subnet in spoke-vnet"
  value       = azurerm_subnet.application_gateway_subnet.id
}
