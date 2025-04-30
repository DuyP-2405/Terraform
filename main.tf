#Cấu hình Terraform với nhà cung cấp azurerm và phiên bản 4.9.0.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
}
#Thiết lập nhà cung cấp azurerm với các thông tin như subscription_id, client_id, client_secret, tenant_id.
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}
#Tạo Resource Group có tên là projectsemIII tại vị trí Đông Nam Á.
resource "azurerm_resource_group" "CyberWatch" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_network_ddos_protection_plan" "DDos" {
  name                = "DDOS-plan"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
}
#Tạo ba mạng ảo (VNET): HubVnet, ProductVnet, DevVnet với các dải địa chỉ riêng biệt.
resource "azurerm_virtual_network" "HubVnet" {
  name                = "HubVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.CyberWatch.name

  ddos_protection_plan {
    enable =  true
    id     =  azurerm_network_ddos_protection_plan.DDos.id
  }
}

resource "azurerm_virtual_network" "ProductVnet" {
  name                = "ProductVnet"
  address_space       = ["11.0.0.0/16"]
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
}

resource "azurerm_virtual_network" "DevVnet" {
  name                = "DevVnet"
  address_space       = ["12.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
}
#Tạo các subnet cho các mạng ảo, bao gồm HubSubnet, AzureBastionSubnet, FWSubnet, LBSubnet(HubVnet), ProductSubnet(ProductVNEt), DevSubnet(DevVnet).
resource "azurerm_subnet" "HubSubnet" {
  name                 = "HubSubnet"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.HubVnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "HubSubnet2" {
  name                 = "HubSubnet2"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.HubVnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.HubVnet.name
  address_prefixes     = ["10.0.255.0/27"]
}
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.HubVnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "ProductSubnet" {
  name                 = "ProductSubnet"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.ProductVnet.name
  address_prefixes     = ["11.0.1.0/24"]
}
resource "azurerm_subnet" "ProductSubnet2" {
  name                 = "ProductSubnet2"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.ProductVnet.name
  address_prefixes     = ["11.0.2.0/24"]
}

resource "azurerm_subnet" "DevSubnet" {
  name                 = "DevSubnet"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.DevVnet.name
  address_prefixes     = ["12.0.1.0/24"]
}

resource "azurerm_subnet" "FWSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  virtual_network_name = azurerm_virtual_network.HubVnet.name
  address_prefixes     = ["10.0.4.0/24"]
}















