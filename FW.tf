# Tạo Firewall với địa chỉ IP công cộng FirewallPublicIP và cấu hình IP cho Firewall.
resource "azurerm_public_ip" "firewallPIP" {
  name                = "FirewallPublicIP"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "HubFirewall" {
  name                = "HubFirewall"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "FirewallIPConfig"
    subnet_id            = azurerm_subnet.FWSubnet.id
    public_ip_address_id = azurerm_public_ip.firewallPIP.id
  }
}
# Tạo các quy tắc NAT cho Firewall để chuyển tiếp HTTP và HTTPS đến địa chỉ IP nội bộ của ProductLB.
resource "azurerm_firewall_nat_rule_collection" "FirewallDNATRules" {
  name                = "DNATRules"
  azure_firewall_name = azurerm_firewall.HubFirewall.name
  resource_group_name = azurerm_resource_group.CyberWatch.name
  priority            = 100
  action              = "Dnat"

  rule {
    name                   = "SSh-Rule"
    protocols              = ["TCP"]
    source_addresses       = ["*"]
    destination_addresses  = [azurerm_public_ip.firewallPIP.ip_address]
    destination_ports      = ["22"]
    translated_address     = azurerm_linux_virtual_machine.DevVM.private_ip_address
    translated_port        = "22"
  }
}
