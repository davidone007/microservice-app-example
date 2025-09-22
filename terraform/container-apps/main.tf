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
    max_replicas = 1
  }
  target_port      = 8080
  is_external      = true
  tags             = var.tags
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
    max_replicas = 1
  }
  target_port      = 8082
  is_external      = false
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
  cpu                          = 0.5
  memory                       = "1.0Gi"
  scale = {
    min_replicas = 1
    max_replicas = 1
  }
  target_port = 8083
  is_external = false
  env = [
    {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:postgresql://${data.terraform_remote_state.base.outputs.postgresql_server_name}.postgres.database.azure.com:5432/users?sslmode=require"
    },
    {
      name  = "SPRING_DATASOURCE_USERNAME"
      value = data.terraform_remote_state.base.outputs.postgresql_admin_username
    },
    {
      name  = "SPRING_DATASOURCE_PASSWORD"
      value = data.terraform_remote_state.base.outputs.postgresql_admin_password
    },
    {
      name  = "SPRING_JPA_HIBERNATE_DDL_AUTO"
      value = "update"
    }
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
    max_replicas = 1
  }
  target_port = 8081
  is_external = false
  env = [
    {
      name  = "REDIS_URL"
      value = data.terraform_remote_state.base.outputs.redis_url
    }
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
    max_replicas = 1
  }
  target_port        = 8084
  is_external        = false
  tags               = var.tags
  acr_admin_username = data.terraform_remote_state.base.outputs.acr_admin_username
  acr_admin_password = data.terraform_remote_state.base.outputs.acr_admin_password
}
