# Tạo Bastion Host với địa chỉ IP công cộng và gán nó vào AzureBastionSubnet.
resource "azurerm_public_ip" "Bastion" {
  name                = "Bastionpip"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "BastionHost" {
  name                = "bastionhost"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.Bastion.id
  }
}
# Tạo kết nối peering giữa các VNET: HubVnet và ProductVnet, HubVnet và DevVnet.
    #Hub-Product
resource "azurerm_virtual_network_peering" "hub-product" {
  name                      = "hub-product"
  resource_group_name       = azurerm_resource_group.CyberWatch.name
  virtual_network_name      = azurerm_virtual_network.HubVnet.name
  remote_virtual_network_id = azurerm_virtual_network.ProductVnet.id
}

resource "azurerm_virtual_network_peering" "product-hub" {
  name                      = "product-hub"
  resource_group_name       = azurerm_resource_group.CyberWatch.name
  virtual_network_name      = azurerm_virtual_network.ProductVnet.name
  remote_virtual_network_id = azurerm_virtual_network.HubVnet.id
}
    #Hub-Dev
resource "azurerm_virtual_network_peering" "hub-dev" {
  name                      = "hub-dev"
  resource_group_name       = azurerm_resource_group.CyberWatch.name
  virtual_network_name      = azurerm_virtual_network.HubVnet.name
  remote_virtual_network_id = azurerm_virtual_network.DevVnet.id
}

resource "azurerm_virtual_network_peering" "dev-hub" {
  name                      = "dev-hub"
  resource_group_name       = azurerm_resource_group.CyberWatch.name
  virtual_network_name      = azurerm_virtual_network.DevVnet.name
  remote_virtual_network_id = azurerm_virtual_network.HubVnet.id
}
