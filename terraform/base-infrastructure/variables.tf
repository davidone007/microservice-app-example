variable "resource_group_name" {
  description = "Nombre del grupo de recursos."
  type        = string
  default     = "microservices-rg"
}

variable "location" {
  description = "Ubicación de los recursos de Azure."
  type        = string
  default     = "centralus"
}

variable "acr_name" {
  description = "Nombre del Azure Container Registry."
  type        = string
  default     = "microservicesacr20250920"
}

variable "key_vault_name" {
  description = "Nombre del Azure Key Vault."
  type        = string
  default     = "msapp-kv-20250920"
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

