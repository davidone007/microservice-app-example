terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "b05f5d22-9a6a-4a96-b58d-8d90aebd2986"
  features {}
}



module "container_app_env" {
  source                     = "./modules/container-app-env"
  name                       = "cae-microservices"
  location                   = data.terraform_remote_state.base.outputs.location
  resource_group_name        = data.terraform_remote_state.base.outputs.resource_group_name
  log_analytics_workspace_id = data.terraform_remote_state.base.outputs.log_analytics_workspace_id
  container_apps_subnet_id   = data.terraform_remote_state.base.outputs.container_apps_subnet_id
  tags                       = var.tags
}

module "frontend" {
  source                       = "./modules/container-app"
  name                         = "frontend"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/frontend:latest"
  cpu                          = 0.25
  memory                       = "0.5Gi"
  scale = {
    min_replicas = 1
    max_replicas = 5
    rules = [
      {
        name = "http-rule"
        type = "http"
        metadata = {
          "concurrentRequests" = "5"
        }
      }
    ]
  }
  target_port      = 80
  is_external      = true
  tags             = var.tags
  env = [
    { name = "PORT",           value = "80" },
    { name = "AUTH_API_PORT",  value = "80" },
    { name = "AUTH_HOST",      value = "auth-api" },
    { name = "TODO_API_PORT",  value = "80" },
    { name = "TODOS_API_HOST", value = "todos-api" },
    { name = "ZIPKIN_PORT",    value = "80/api/v2/spans" },
    { name = "ZIPKIN_HOST",    value = "zipkin" }
  ]
  acr_admin_username = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password = data.terraform_remote_state.base.outputs.acr_admin_password
}

module "todos_api" {
  source                       = "./modules/container-app"
  name                         = "todos-api"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/todos-api:latest"
  cpu                          = 0.25
  memory                       = "0.5Gi"
  scale = {
    min_replicas = 1
    max_replicas = 5
    rules = [
      {
        name = "cpu-scaling"
        type = "cpu"
        metadata = {
          "type"  = "Utilization"
          "value" = "80"
        }
      }
    ]
  }
  target_port      = 8082
  is_external      = true
  env = [
    { name = "JWT_SECRET",     value = "PRFT" },
    { name = "TODO_API_PORT",  value = "8082" },
    { name = "REDIS_HOST",     value = "redis" },
    { name = "REDIS_PORT",     value = "6379" },
    { name = "REDIS_CHANNEL",  value = "log_channel" },
    { name = "ZIPKIN_URL",     value = "http://zipkin:80/api/v2/spans" }
  ]
  tags             = var.tags
  acr_admin_username = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password = data.terraform_remote_state.base.outputs.acr_admin_password
}

module "users_api" {
  source                       = "./modules/container-app"
  name                         = "users-api"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/users-api:latest"
  cpu                          = 1.0
  memory                       = "2.0Gi"
  scale = {
    min_replicas = 1
    max_replicas = 5
    rules = [
      {
        name = "cpu-scaling"
        type = "cpu"
        metadata = {
          "type"  = "Utilization"
          "value" = "75"
        }
      }
    ]
  }
  target_port = 8083
  is_external = true
  env = [
    {
      name  = "SERVER_PORT"
      value = "8083"
    },
    { name = "JWT_SECRET",
      value = "PRFT"
    },
    { name = "ZIPKIN_URL",
      value = "http://zipkin:80/api/v2/spans"
    },
    {
      name  = "SPRING_PROFILES_ACTIVE"
      value = "prod"
    },
    
  ]
  tags               = var.tags
  acr_admin_username = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password = data.terraform_remote_state.base.outputs.acr_admin_password
}

module "auth_api" {
  source                       = "./modules/container-app"
  name                         = "auth-api"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/auth-api:latest"
  cpu                          = 0.5
  memory                       = "1.0Gi"
  scale = {
    min_replicas = 1
    max_replicas = 3
    rules = [
      {
        name = "cpu-scaling"
        type = "cpu"
        metadata = {
          "type"  = "Utilization"
          "value" = "70"
        }
      }
    ]
  }
  target_port = 8000
  is_external = true
  env = [
    { name = "JWT_SECRET",        value = "PRFT" },
    { name = "AUTH_API_PORT",     value = "8000" },
    { name = "USERS_API_ADDRESS", value = "http://users-api:80" },
    { name = "ZIPKIN_URL",        value = "http://zipkin:80/api/v2/spans" },
    { name = "REDIS_HOST",        value = "redis" },
    { name = "REDIS_PORT",        value = "6379" }
  ]
  tags               = var.tags
  acr_admin_username = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password = data.terraform_remote_state.base.outputs.acr_admin_password
}

module "log_message_processor" {
  source                       = "./modules/container-app"
  name                         = "log-message-processor"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/log-message-processor:latest"
  cpu                          = 0.5
  memory                       = "1.0Gi"
  scale = {
    min_replicas = 1
    max_replicas = 2
    rules = [
      {
        name = "cpu-scaling"
        type = "cpu"
        metadata = {
          "type"  = "Utilization"
          "value" = "80"
        }
      }
    ]
  }
  target_port        = 8084
  is_external        = true
  env = [
    { name = "REDIS_HOST",    value = "redis" },
    { name = "REDIS_PORT",    value = "6379" },
    { name = "REDIS_CHANNEL", value = "log_channel" },
    { name = "PYTHONUNBUFFERED", value = "1" },
    { name = "ZIPKIN_URL",    value = "http://zipkin:80/api/v2/spans" }
  ]
  tags               = var.tags
  acr_admin_username = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password = data.terraform_remote_state.base.outputs.acr_admin_password
}

module "zipkin" {
  source                       = "./modules/container-app"
  name                         = "zipkin"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/zipkin:latest"
  cpu                          = 0.25
  memory                       = "0.5Gi"
  target_port                  = 9411
  is_external                  = true
  tags                         = var.tags
  acr_admin_username           = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password           = data.terraform_remote_state.base.outputs.acr_admin_password
}

module "redis" {
  source                       = "./modules/container-app"
  name                         = "redis"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "redis:7-alpine" # Using public image for Redis
  cpu                          = 0.25
  memory                       = "0.5Gi"
  target_port                  = 6379
  is_external                  = false # Internal service
  is_public_image              = true
  tags                         = var.tags
  acr_admin_username           = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password           = data.terraform_remote_state.base.outputs.acr_admin_password
}
