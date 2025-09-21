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
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/frontend:${var.image_tag}"
  is_external                  = true
  target_port                  = 80
  cpu                          = 0.5
  memory                       = "1.0Gi"
  tags                         = var.tags
}

module "users_api" {
  source                       = "./modules/container-app"
  name                         = "users-api"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/users-api:${var.image_tag}"
  is_external                  = false
  target_port                  = 8083
  cpu                          = 0.5
  memory                       = "1.0Gi"
  tags                         = var.tags
}

module "auth_api" {
  source                       = "./modules/container-app"
  name                         = "auth-api"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/auth-api:${var.image_tag}"
  is_external                  = true
  target_port                  = 8000
  cpu                          = 0.25
  memory                       = "0.5Gi"
  env = [
    { name = "USERS_API_ADDRESS", value = "http://${module.users_api.fqdn}" }
  ]
  tags = var.tags
}

module "todos_api" {
  source                       = "./modules/container-app"
  name                         = "todos-api"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/todos-api:${var.image_tag}"
  is_external                  = true
  target_port                  = 8082
  cpu                          = 0.5
  memory                       = "1.0Gi"
  key_vault_id                 = data.terraform_remote_state.base.outputs.key_vault_id
  key_vault_uri                = data.terraform_remote_state.base.outputs.key_vault_uri
  secrets                      = {}
  tags                         = var.tags
}

module "log_message_processor" {
  source                       = "./modules/container-app"
  name                         = "log-message-processor"
  resource_group_name          = data.terraform_remote_state.base.outputs.resource_group_name
  container_app_environment_id = module.container_app_env.id
  image_name                   = "${data.terraform_remote_state.base.outputs.acr_login_server}/log-message-processor:${var.image_tag}"
  is_external                  = false
  target_port                  = 80
  cpu                          = 0.25
  memory                       = "0.5Gi"
  key_vault_id                 = data.terraform_remote_state.base.outputs.key_vault_id
  key_vault_uri                = data.terraform_remote_state.base.outputs.key_vault_uri
  secrets                      = {}
  scale = {
    min_replicas = 1
    max_replicas = 1
  }
  tags = var.tags
}

# Grant AcrPull to the container apps managed identities so they can pull images from the ACR
data "azurerm_role_definition" "acr_pull" {
  name = "AcrPull"
}

resource "azurerm_role_assignment" "frontend_acr_pull" {
  scope                = data.terraform_remote_state.base.outputs.acr_id
  role_definition_id   = data.azurerm_role_definition.acr_pull.id
  principal_id         = module.frontend.principal_id
}

resource "azurerm_role_assignment" "users_api_acr_pull" {
  scope                = data.terraform_remote_state.base.outputs.acr_id
  role_definition_id   = data.azurerm_role_definition.acr_pull.id
  principal_id         = module.users_api.principal_id
}

resource "azurerm_role_assignment" "auth_api_acr_pull" {
  scope                = data.terraform_remote_state.base.outputs.acr_id
  role_definition_id   = data.azurerm_role_definition.acr_pull.id
  principal_id         = module.auth_api.principal_id
}

resource "azurerm_role_assignment" "todos_api_acr_pull" {
  scope                = data.terraform_remote_state.base.outputs.acr_id
  role_definition_id   = data.azurerm_role_definition.acr_pull.id
  principal_id         = module.todos_api.principal_id
}

resource "azurerm_role_assignment" "log_message_processor_acr_pull" {
  scope                = data.terraform_remote_state.base.outputs.acr_id
  role_definition_id   = data.azurerm_role_definition.acr_pull.id
  principal_id         = module.log_message_processor.principal_id
}
