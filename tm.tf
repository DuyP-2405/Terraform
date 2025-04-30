# Định tuyến HubRouteTable và thêm tuyến đến ProductVnet. Gán bảng định tuyến này cho HubSubnet.
resource "azurerm_route_table" "hub_route_table" {
  name                = "HubRouteTable"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
}

resource "azurerm_route" "route_to_product_vnet" {
  name                   = "route-to-product"
  route_table_name       = azurerm_route_table.hub_route_table.name
  resource_group_name    = azurerm_resource_group.CyberWatch.name
  address_prefix         = "11.0.0.0/24" 
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_public_ip.alb-pip.ip_address
  }
resource "azurerm_subnet_route_table_association" "hub_subnet_route_table" {
  subnet_id      = azurerm_subnet.HubSubnet.id
  route_table_id = azurerm_route_table.hub_route_table.id
}

# Create Traffic Manager profile
resource "azurerm_traffic_manager_profile" "TrafficManager" {
  name                   = "TM-profile"
  resource_group_name    = azurerm_resource_group.CyberWatch.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "Cyberwatch-profile"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_external_endpoint" "JW" {
  name                 = "JW-endpoint"
  profile_id           = azurerm_traffic_manager_profile.TrafficManager.id
  always_serve_enabled = true
  weight               = 70
  target               = "jw.duyplab.site"
  priority             = 1
}
resource "azurerm_traffic_manager_external_endpoint" "JE" {
  name                 = "JE-endpoint"
  profile_id           = azurerm_traffic_manager_profile.TrafficManager.id
  always_serve_enabled = true
  weight               = 30
  target               = "je.duyplab.site"
  priority             = 2
}
