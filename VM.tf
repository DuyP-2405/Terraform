#Tạo các NSG cho các máy ảo như DevVM và ProductVMSS với các quy tắc bảo mật cho HTTP, HTTPS và RDP.
    #Dev VM NSG
resource "azurerm_network_security_group" "DevVM" {
  name                = "DevVM-nsg"
  location            = var.location
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
    name                       = "allow-ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Tạo NIC cho máy ảo DevVM và gán NSG cho NIC này.
    #DEV VM NIC
resource "azurerm_network_interface" "DEVNIC" {
  name                = "DEVVM-NIC"
  location            = var.location
  resource_group_name = azurerm_resource_group.CyberWatch.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.DevSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

    #Dev NSG to dev NIC
resource "azurerm_network_interface_security_group_association" "DEV" {
  network_interface_id      = azurerm_network_interface.DEVNIC.id
  network_security_group_id = azurerm_network_security_group.DevVM.id
}

#Tạo máy ảo Windows DevVM và gán NIC với các thông số như tên, vị trí, kích thước, thông tin đăng nhập và hệ điều hành.
# Tạo Storage Container
resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_id    = azurerm_storage_account.duypfinal_storage.id
  container_access_type = "private"
}

# Upload Script lên Blob
resource "azurerm_storage_blob" "web_server_script" {
  name                   = "install_web_server.sh"
  storage_account_name   = azurerm_storage_account.duypfinal_storage.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "./install_web_server.sh"
}

# Khởi tạo SAS Token
data "azurerm_storage_account_sas" "duypfinal_sas" {
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

# Tạo linux-VM chạy web
resource "azurerm_linux_virtual_machine" "DevVM" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.CyberWatch.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.DEVNIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
custom_data = base64encode(<<-EOT
    #!/bin/bash
    sudo wget -O /tmp/install_web_server.sh "https://${azurerm_storage_account.duypfinal_storage.name}.blob.core.windows.net/${azurerm_storage_container.scripts.name}/install_web_server.sh?${data.azurerm_storage_account_sas.duypfinal_sas.sas}"
    cd /tmp
    sudo chmod +x install_web_server.sh
    ./install_web_server.sh
EOT
)
}
#Tạo đĩa quản lý DevDisk với kích thước 4 GB và gắn kết đĩa này vào máy ảo DevVM.
resource "azurerm_managed_disk" "DevDisk" {
  name                 = "DevDisk"
  location             = var.location
  resource_group_name  = azurerm_resource_group.CyberWatch.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}
resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  virtual_machine_id = azurerm_linux_virtual_machine.DevVM.id  
  managed_disk_id     = azurerm_managed_disk.DevDisk.id
  lun                 = 0  
  caching             = "ReadWrite"  
}
