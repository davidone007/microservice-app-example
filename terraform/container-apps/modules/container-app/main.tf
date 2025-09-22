data "azurerm_client_config" "current" {}

resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  registry {
    server               = split("/", var.image_name)[0]
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
  }

  identity {
    type = "SystemAssigned"
  }

  template {
    min_replicas = var.scale != null ? var.scale.min_replicas : 0
    max_replicas = var.scale != null ? var.scale.max_replicas : 1

    # Reglas de autoscaling HTTP
    dynamic "http_scale_rule" {
      for_each = var.scale != null ? [for rule in var.scale.rules : rule if rule.type == "http"] : []
      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.metadata["concurrentRequests"]
      }
    }

    # Reglas de autoscaling basadas en CPU
    dynamic "custom_scale_rule" {
      for_each = var.scale != null ? [for rule in var.scale.rules : rule if rule.type == "cpu"] : []
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = "cpu"
        metadata = {
          "type" = "Utilization"
          "value" = custom_scale_rule.value.metadata["value"]
        }
      }
    }

    container {
      name   = var.name
      image  = var.image_name
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
    }
  }

  ingress {
    external_enabled = var.is_external
    target_port      = var.target_port
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name                = lower(replace(secret.key, "_", "-"))
      key_vault_secret_id = secret.value
    }
  }
}

resource "azurerm_key_vault_access_policy" "main" {
  # Solo crea la política si hay secretos que usar
  count = length(keys(var.secrets)) > 0 ? 1 : 0

  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_container_app.main.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}
