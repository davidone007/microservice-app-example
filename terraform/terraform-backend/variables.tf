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

variable "subscription_id" {
  description = "(Optional) Subscription ID to target. If not provided, the provider will use the Azure CLI default subscription."
  type        = string
  default     = "b05f5d22-9a6a-4a96-b58d-8d90aebd2986"
}
