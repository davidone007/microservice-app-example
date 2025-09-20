variable "image_tag" {
  description = "La etiqueta de la imagen a desplegar para todos los servicios."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Etiquetas comunes para los recursos."
  type        = map(string)
  default = {
    project = "microservice-app-example"
    env     = "dev"
  }
}
