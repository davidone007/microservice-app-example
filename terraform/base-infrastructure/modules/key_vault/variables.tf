variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tenant_id" { type = string }
variable "object_id" { type = string }
variable "tags" { type = map(string) }

variable "redis_primary_connection_string" {
  type      = string
  sensitive = true
}
variable "redis_hostname" {
  type      = string
  sensitive = true
}
variable "redis_ssl_port" {
  type      = number
  sensitive = true
}
variable "redis_primary_access_key" {
  type      = string
  sensitive = true
}
variable "postgresql_db_server_name" {
  type      = string
  sensitive = true
}
variable "postgresql_db_name" {
  type      = string
  sensitive = true
}
variable "postgresql_db_admin_username" {
  type      = string
  sensitive = true
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "db_admin_password" {
  type      = string
  sensitive = true
}
