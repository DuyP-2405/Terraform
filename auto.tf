# Upload Script lên Blob
resource "azurerm_storage_blob" "CreateAndAttachNewDisk" {
  name                   = "CreateAndAttachNewDisk.ps1"
  storage_account_name   = azurerm_storage_account.duypfinal_storage.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "./CreateAndAttachNewDisk.ps1"
}
data "azurerm_storage_account_sas" "duypfinal_sas1" {
  connection_string = azurerm_storage_account.duypfinal_storage.primary_connection_string
  https_only        = true
  signed_version    = "2020-08-04"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-12-01T00:00:00Z"
  expiry = "2024-12-31T23:59:59Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = true
  }
}
# Automation Account
resource "azurerm_automation_account" "auto" {
  name                = "automation-account"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
}

#Role Assignment to allow Automation Account to manage resources
resource "azurerm_role_assignment" "4auto" {
  principal_id   = azurerm_automation_account.auto.identity[0].principal_id
  role_definition_name = "Contributor"  # or any other role based on your needs
  scope           = azurerm_resource_group.CyberWatch.id
}

# Automation Runbook
resource "azurerm_automation_runbook" "runbook" {
  name                    = "Get-Disk"
  location                = azurerm_resource_group.CyberWatch.location
  resource_group_name     = azurerm_resource_group.CyberWatch.name
  automation_account_name = azurerm_automation_account.auto.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an runbook to attach disk"
  runbook_type            = "PowerShell"

  publish_content_link {
    uri = "https://${azurerm_storage_account.duypfinal_storage.name}.blob.core.windows.net/${azurerm_storage_container.scripts.name}/CreateAndAttachNewDisk.ps1?${data.azurerm_storage_account_sas.duypfinal_sas1.sas}"
  }
}
resource "azurerm_automation_webhook" "webhook" {
  name                    = "runbook"
  resource_group_name     = azurerm_resource_group.CyberWatch.name
  automation_account_name = azurerm_automation_account.auto.name
  enabled                 = true
  expiry_time             = "2024-12-31T23:59:59Z"
  runbook_name            = azurerm_automation_runbook.runbook.name
}

# Update Monitor Action Group to Include Runbook Action
resource "azurerm_monitor_action_group" "vm_alert_action_group1" {
  name                = "vm-alert-action-group"
  resource_group_name = azurerm_resource_group.CyberWatch.name
  location            = "global"
  short_name          = "adminalert"

  webhook_receiver {
    name        = "RunbookExecution"
    service_uri = "https://${azurerm_storage_account.duypfinal_storage.name}.blob.core.windows.net/${azurerm_storage_container.scripts.name}/CreateAndAttachNewDisk.ps1?${data.azurerm_storage_account_sas.duypfinal_sas1.sas}"
  }
}

# Metric Alert for VM data disk
resource "azurerm_monitor_metric_alert" "vm_data_disk_alert" {
  name                = "vm-disk-usage-alert"
  resource_group_name = azurerm_resource_group.CyberWatch.name
  description         = "Alert when VM data disk usage reaches 70%."
  enabled             = true
  scopes              = [azurerm_managed_disk.DevDisk.id]
  
  criteria {
    metric_namespace = "microsoft.compute/disks"
    metric_name      = "Composite Disk Write Bytes/sec"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 10000
  }

  action {
    action_group_id = azurerm_monitor_action_group.vm_alert_action_group1.id
  }
}
