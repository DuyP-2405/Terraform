resource "azurerm_route_table" "route" {
  name                = "route-table"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name

  route {
    name           = "route1"
    address_prefix = "11.0.1.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_linux_virtual_machine.DevVM.private_ip_address
      }
  route {
    name           = "route2"
    address_prefix = "12.0.1.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_lb.ProductLB2.frontend_ip_configuration[0].private_ip_address
}
}