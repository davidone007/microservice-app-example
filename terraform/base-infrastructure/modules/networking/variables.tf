variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

variable "subnets" {
  type = map(string)
  default = {
    "container-apps-subnet" = "10.0.0.0/23"

  }
}
