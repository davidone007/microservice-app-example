variable "resource_group_name" {
  description = "Name of the resource group to create for tfstate"
  type        = string
  default     = "tfstate-rg-microservices"
}

variable "location" {
  description = "Location for the resource group and storage account"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Storage account name for terraform state (unique globally)"
  type        = string
  default     = "tfstatemsapp20250920ac"
}

variable "container_name" {
  description = "Blob container name for terraform state files"
  type        = string
  default     = "tfstate"
}

variable "key" {
  description = "Key (file name) for the terraform state blob"
  type        = string
  default     = "backend.terraform.tfstate"
}
