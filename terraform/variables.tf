variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-microservice-todo"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "microservice-todo"
}

variable "acr_sku" {
  description = "ACR SKU"
  type        = string
  default     = "Standard"
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B1"
}

variable "redis_sku" {
  description = "Redis Cache SKU"
  type        = string
  default     = "Basic"
}

variable "redis_family" {
  description = "Redis Cache family"
  type        = string
  default     = "C"
}

variable "redis_capacity" {
  description = "Redis Cache capacity"
  type        = number
  default     = 0
}

variable "allowed_ips" {
  description = "List of allowed IP addresses for security"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this in production
}
