variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

variable "subnets" {
  type = map(string)
  default = {
    "container-apps-subnet" = "10.0.0.0/23"
    "redis-subnet"          = "10.0.2.0/24"
    "postgresql-subnet"     = "10.0.3.0/24"
  }
}
