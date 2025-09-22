variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "container_app_environment_id" {
  type = string
}
variable "acr_admin_username" {
  type      = string
  sensitive = true
}
variable "acr_admin_password" {
  type      = string
  sensitive = true
}
variable "image_name" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "key_vault_uri" {
  type    = string
  default = ""
}
variable "key_vault_id" {
  type    = string
  default = ""
}

variable "is_external" {
  type    = bool
  default = false
}
variable "target_port" {
  type = number
}
variable "cpu" {
  type    = number
  default = 0.25
}
variable "memory" {
  type    = string
  default = "0.5Gi"
}

variable "env" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  type    = map(string)
  default = {}
}

variable "scale" {
  type = object({
    min_replicas = number
    max_replicas = number
    rules = optional(list(object({
      name = string
      type = string  # "http", "cpu", "memory", "azure-queue", etc.
      metadata = map(string)
    })), [])
  })
  default = null
}
