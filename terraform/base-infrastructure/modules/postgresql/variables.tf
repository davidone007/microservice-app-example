
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
