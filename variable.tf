variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "your-sub-ID"
}

variable "client_id" {
  description = "Azure client ID"
  type        = string
  default     = "your-client-ID"
}

variable "client_secret" {
  description = "Azure client secret"
  type        = string
  default     = "your-sub-secret"
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = "your-tenant-ID"
}
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "CyberWatch"
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "Japan West"
}
variable "location2" {
  description = "Azure location 2 for resources"
  type        = string
  default     = "Japan East"
}
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "DevVM"
}
variable "scaleset_name1" {
  description = "Name of the scaleset"
  type        = string
  default     = "Product1"
}
variable "scaleset_name2" {
  description = "Name of the scaleset"
  type        = string
  default     = "Product2"
}
variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "adminuser"
}
variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  default     = "your-pass"
}
variable "admin_db" {
  description = "Admin username for the DBserver"
  type        = string
  default     = "mysqladminun"
}
variable "admin_db_pw" {
  description = "Admin password for the DBserver"
  type        = string
  default     = "your-pass"
}


variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}



variable "email_address" {
  description = "Email address for the alert"
  type        = string
  default     = "your-alerting-mail"
}
variable "ddos_protection_plan_enabled" {
  type        = bool
  description = "Enable DDoS protection plan."
  default     = true
}  



