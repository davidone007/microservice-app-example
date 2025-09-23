variable "subscription_id" {
  description = "ID de la suscripción de Azure donde se desplegarán los recursos."
  type        = string
}

variable "image_tags" {
  description = "Mapa con los tags de las imágenes Docker para cada servicio."
  type        = map(string)
  default = {
    "auth-api"              = "latest"
    "todos-api"             = "latest"
    "users-api"             = "latest"
    "frontend"              = "latest"
    "log-message-processor" = "latest"
  }
}

variable "tags" {
  description = "Etiquetas comunes para los recursos."
  type        = map(string)
  default = {
    project = "microservice-app-example"
    env     = "dev"
  }
}
