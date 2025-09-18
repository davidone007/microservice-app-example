# Auth API (Go)
resource "azurerm_linux_web_app" "auth_api" {
  name                = "app-auth-api-${var.environment}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.common_tags

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "auth-api"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.main.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.main.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.main.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "AUTH_API_PORT"                       = "8000"
    "USERS_API_ADDRESS"                   = "https://${azurerm_linux_web_app.users_api.default_hostname}"
    "JWT_SECRET"                          = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_secret.id})"
    "ZIPKIN_URL"                          = "http://127.0.0.1:9411/api/v2/spans"
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.app_services.id
}

# Users API (Java/Spring Boot)
resource "azurerm_linux_web_app" "users_api" {
  name                = "app-users-api-${var.environment}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.common_tags

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "users-api"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.main.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.main.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.main.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "SERVER_PORT"                         = "8083"
    "JWT_SECRET"                          = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_secret.id})"
    "SPRING_ZIPKIN_BASEURL"               = "http://127.0.0.1:9411/"
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.app_services.id
}

# TODOs API (Node.js)
resource "azurerm_linux_web_app" "todos_api" {
  name                = "app-todos-api-${var.environment}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.common_tags

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "todos-api"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.main.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.main.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.main.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "TODO_API_PORT"                       = "8082"
    "JWT_SECRET"                          = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.jwt_secret.id})"
    "REDIS_HOST"                          = azurerm_redis_cache.main.hostname
    "REDIS_PORT"                          = azurerm_redis_cache.main.ssl_port
    "REDIS_CHANNEL"                       = "log_channel"
    "ZIPKIN_URL"                          = "http://127.0.0.1:9411/api/v2/spans"
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.app_services.id
}

# Log Message Processor (Python)
resource "azurerm_linux_web_app" "log_processor" {
  name                = "app-log-processor-${var.environment}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.common_tags

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "log-processor"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.main.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.main.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.main.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "REDIS_HOST"                          = azurerm_redis_cache.main.hostname
    "REDIS_PORT"                          = azurerm_redis_cache.main.ssl_port
    "REDIS_CHANNEL"                       = "log_channel"
    "ZIPKIN_URL"                          = "http://127.0.0.1:9411/api/v2/spans"
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.app_services.id
}

# Frontend (Vue.js)
resource "azurerm_linux_web_app" "frontend" {
  name                = "app-frontend-${var.environment}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.common_tags

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "frontend"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.main.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.main.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.main.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "PORT"                                = "8080"
    "AUTH_API_ADDRESS"                    = "https://${azurerm_linux_web_app.auth_api.default_hostname}"
    "TODOS_API_ADDRESS"                   = "https://${azurerm_linux_web_app.todos_api.default_hostname}"
    "ZIPKIN_URL"                          = "http://127.0.0.1:9411/api/v2/spans"
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.app_services.id
}

# Key Vault access policies for App Services
resource "azurerm_key_vault_access_policy" "auth_api" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.auth_api.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "users_api" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.users_api.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "todos_api" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.todos_api.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}
