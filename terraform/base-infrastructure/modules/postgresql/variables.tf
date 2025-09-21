
variable "db_server_name" {
  description = "The name of the PostgreSQL server."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "db_admin_username" {
  description = "The admin username for the PostgreSQL server."
  type        = string

  validation {
    condition = length(var.db_admin_username) >= 3 && length(var.db_admin_username) <= 63 && length(regexall("^[a-z0-9_-]+$", var.db_admin_username)) == 1 && lower(var.db_admin_username) == var.db_admin_username && var.db_admin_username != "admin"
    error_message = "db_admin_username must be 3-63 chars, lowercase letters, digits, '-' or '_', and cannot be 'admin'."
  }
}

variable "db_admin_password" {
  description = "The admin password for the PostgreSQL server."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name of the PostgreSQL database."
  type        = string
}

variable "delegated_subnet_id" {
  description = "The ID of the delegated subnet for PostgreSQL Flexible Server."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network for Private DNS Zone association."
  type        = string
}
