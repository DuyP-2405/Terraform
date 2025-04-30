resource "random_string" "unique_suffix" {
  length  = 5
  special = false
  upper   = false 
}
resource "azurerm_storage_account" "duypfinal_storage" {
  name                     = "cyberwatchsa${random_string.unique_suffix.result}"
  resource_group_name      = azurerm_resource_group.CyberWatch.name
  location                 = azurerm_resource_group.CyberWatch.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}
