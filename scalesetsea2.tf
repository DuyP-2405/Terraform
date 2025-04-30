resource "azurerm_windows_virtual_machine_scale_set" "productSEA2" {
  name                 = var.scaleset_name2
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  location             = azurerm_resource_group.CyberWatch.location
  sku                  = var.vm_size
  instances            = 1
  admin_password       = var.admin_password
  admin_username       = var.admin_username
  computer_name_prefix = "vm-"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" 
  }
  data_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb        = 128  
    lun                 = 0    
  }
  
  network_interface {
    name    = "Product2VMSS-NIC"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.ProductSubnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool2.id]

    }
        network_security_group_id = azurerm_network_security_group.ProductVMSS.id
  }
}
resource "azurerm_monitor_autoscale_setting" "scaleconfig2" {
  name                = "scaleconfig2"
  resource_group_name = azurerm_resource_group.CyberWatch.name
  location            = azurerm_resource_group.CyberWatch.location
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.productSEA2.id

  profile {
    name = "DuyP2Profile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.productSEA2.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.productSEA2.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  predictive {
    scale_mode      = "Enabled"
    look_ahead_time = "PT5M"
  }

  notification {
    email {
      custom_emails                         = [var.email_address]
    }
  }
}

    #Product VMSS NSG
resource "azurerm_network_security_group" "ProductVMSS2" {
  name                = "ProductVMSS-nsg"
  location            = azurerm_resource_group.CyberWatch.location
  resource_group_name = azurerm_resource_group.CyberWatch.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
