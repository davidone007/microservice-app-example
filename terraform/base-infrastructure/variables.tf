variable "resource_group_name" {
  description = "Nombre del grupo de recursos."
  type        = string
  default     = "microservices-rg"
}

variable "location" {
  description = "Ubicación de los recursos de Azure."
  type        = string
  default     = "westeurope"
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry."
  type        = string
  default     = "microservicesacrtaller"
}

variable "redis_name" {
  description = "Nombre de la instancia de Azure Cache for Redis."
  type        = string
  default     = "microservices-redis-cache"
}

variable "key_vault_name" {
  description = "Nombre del Azure Key Vault."
  type        = string
  default     = "microservices-kv-taller"
}

variable "log_analytics_name" {
  description = "Nombre del Log Analytics Workspace."
  type        = string
  default     = "microservices-log-analytics"
}

variable "jwt_secret" {
  description = "Secreto para los tokens JWT."
  type        = string
  sensitive   = true
  default     = "PRFT" # Valor por defecto del docker-compose.yml
}

variable "tags" {
  description = "Etiquetas comunes para los recursos."
  type        = map(string)
  default = {
    project = "microservice-app-example"
    env     = "dev"
  }
}

variable "key_vault_secrets" {
  description = "A map of secrets to store in the Key Vault."
  type        = map(string)
  default = {
    "jwt-secret" = "default-jwt-secret-for-dev"
  }
}

variable "db_server_name" {
  description = "The name of the PostgreSQL server."
  type        = string
  default     = "microservices-db-server-taller"
}

variable "db_name" {
  description = "The name of the PostgreSQL database."
  type        = string
  default     = "todos_db"
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
