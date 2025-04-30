# Tạo DNS zone duyplab.site và các bản ghi DNS A và CNAME.
resource "azurerm_dns_zone" "DNS-public" {
  name                = "duyplab.site"
  resource_group_name = azurerm_resource_group.CyberWatch.name
}
resource "azurerm_dns_a_record" "dns-a-record" {
  name                = "@"
  zone_name           = azurerm_dns_zone.DNS-public.name
  resource_group_name = azurerm_resource_group.CyberWatch.name
  ttl                 = 3600
  records             = [azurerm_public_ip.alb-pip.ip_address]
}
resource "azurerm_dns_cname_record" "dns-cname" {
  name                = "www"
  zone_name           = azurerm_dns_zone.DNS-public.name
  resource_group_name = azurerm_resource_group.CyberWatch.name
  ttl                 = 300
  record              = "duyplab.site"
}

