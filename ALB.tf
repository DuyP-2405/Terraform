resource "azurerm_public_ip" "alb-pip" {
  name                = "alb-pip"
  resource_group_name = azurerm_resource_group.CyberWatch.name
  location            = azurerm_resource_group.CyberWatch.location
  allocation_method   = "Static"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.HubVnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.HubVnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.HubVnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.HubVnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.HubVnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.HubVnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.HubVnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "ProductALB" {
  name                = "ProductALB-appgateway"
  resource_group_name = azurerm_resource_group.CyberWatch.name
  location            = azurerm_resource_group.CyberWatch.location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  request_routing_rule {
    name                           = "ProductALB-RoutingRule"
    rule_type                      = "PathBasedRouting"
    http_listener_name             = local.listener_name
    url_path_map_name              = "ProductALB-PathMap"
    priority                       = 1 
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.HubSubnet2.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  firewall_policy_id = azurerm_web_application_firewall_policy.WAF-policy.id
  
force_firewall_policy_association = true
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.alb-pip.id
  }

  backend_address_pool {
    name = "ProductALB-Pool1"
    ip_addresses = [
      azurerm_lb.ProductLB.frontend_ip_configuration[0].private_ip_address
    ]
  }

  backend_address_pool {
    name = "ProductALB-Pool2"
    ip_addresses = [
      azurerm_lb.ProductLB2.frontend_ip_configuration[0].private_ip_address
    ]
  }
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  probe {
  name                   = "ALBHealthProbe"
  protocol               = "Http"                      
  path                   = "/health"                   
  interval               = 5                           
  timeout                = 30                           
  unhealthy_threshold    = 3                            
  port                   = 80  
  pick_host_name_from_backend_http_settings = true
                         
  }
  url_path_map {
    name = "ProductALB-PathMap"

    default_backend_address_pool_name  = "ProductALB-Pool1"
    default_backend_http_settings_name = local.http_setting_name
    

  path_rule {
    name                       = "ImagesPathRule"
    paths                      = ["/images/*"]
    backend_address_pool_name  = "ProductALB-Pool2"
    backend_http_settings_name = local.http_setting_name

    }
  
  }
}
