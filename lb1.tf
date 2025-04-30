# Tạo Load Balancer nội bộ ProductLB và các cấu hình liên quan như frontend IP, backend pool, health probe và quy tắc.
resource "azurerm_lb" "ProductLB" {
  name                = "ProductLB"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "LBFrontend"
    subnet_id                     = azurerm_subnet.ProductSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Load Balancer Backend Pool
resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.ProductLB.id
  name            = "BackEndAddressPool"
}

# Load Balancer Rule (HTTP)
resource "azurerm_lb_rule" "ProductLBRule" {
  name                           = "HTTPRule"
  loadbalancer_id                = azurerm_lb.ProductLB.id
  protocol                       = "Tcp"
  frontend_port                  = 80  
  backend_port                   = 80
  frontend_ip_configuration_name = "LBFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  probe_id                       = azurerm_lb_probe.ProductLBHealthProbe.id
}

# Health Probe for LB
resource "azurerm_lb_probe" "ProductLBHealthProbe" {
  loadbalancer_id     = azurerm_lb.ProductLB.id
  name                = "HealthProbe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}