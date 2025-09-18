# Terraform Infrastructure for Microservice TODO App

Esta infraestructura implementa todos los recursos necesarios para desplegar la aplicación de microservicios TODO en Azure usando las mejores prácticas de infraestructura como código.

## 🏗️ Arquitectura

La infraestructura incluye:
- **Azure Container Registry (ACR)** para imágenes Docker
- **Azure App Services** para cada microservicio (5 servicios)
- **Azure Redis Cache** para cola de mensajes
- **Azure Key Vault** para gestión de secretos
- **Virtual Network** con subredes para seguridad
- **Network Security Groups** para control de acceso

## 📋 Prerequisitos

1. **Azure CLI** instalado y configurado
2. **Terraform** instalado (>= 1.0)
3. **Cuenta de Azure** con permisos de contribuidor
4. **Repositorio de GitHub** con secretos configurados

## 🔐 Secretos de GitHub Requeridos

Configura estos secretos en tu repositorio de GitHub:

```
AZURE_CREDENTIALS     - Credenciales del Service Principal para Azure
TERRAFORM_STATE_RG    - Grupo de recursos para el estado de Terraform
TERRAFORM_STATE_STORAGE - Cuenta de almacenamiento para el estado
TERRAFORM_STATE_CONTAINER - Contenedor para el estado de Terraform
```

### Crear Service Principal para Azure

```bash
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID" --sdk-auth
```

## 🚀 Configuración Inicial

### 1. Configurar Backend de Terraform

Primero ejecuta el script para configurar el almacenamiento del estado:

```bash
chmod +x scripts/setup-terraform-backend.sh
./scripts/setup-terraform-backend.sh
```

Este script creará automáticamente:
- Resource Group para el estado de Terraform
- Storage Account con nombre único
- Container para almacenar el archivo de estado

### 2. Configurar Variables

Copia y personaliza el archivo de variables:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edita `terraform.tfvars` según tus necesidades:

```hcl
environment         = "dev"
location           = "East US"
resource_group_name = "rg-microservice-todo"
app_name           = "microservice-todo"
acr_sku            = "Standard"
app_service_plan_sku = "B1"
redis_sku          = "Basic"

# Importante: Cambia esto en producción por tus IPs reales
allowed_ips = ["TU_IP_PUBLICA/32"]
```

### 3. Inicializar y Aplicar Terraform

```bash
cd terraform

# Inicializar Terraform
terraform init

# Validar configuración
terraform validate

# Ver plan de ejecución
terraform plan

# Aplicar cambios
terraform apply
```

## 📦 Recursos Creados

### Container Registry
- **Nombre**: `acr{app_name}{environment}{random_suffix}`
- **Admin habilitado**: Sí (para CI/CD)
- **SKU**: Standard (incluye webhook y scanning)

### App Services (5 servicios)
- **auth-api**: API de autenticación (Go)
- **users-api**: API de usuarios (Java/Spring Boot)
- **todos-api**: API de TODOs (Node.js)
- **log-processor**: Procesador de logs (Python)
- **frontend**: Frontend web (Vue.js)

### Recursos de Soporte
- **Redis Cache**: Para cola de mensajes entre servicios
- **Key Vault**: Para almacenamiento seguro de secretos
- **Virtual Network**: Red privada con subredes
- **NSG**: Reglas de seguridad de red

## 🔄 CI/CD con GitHub Actions

### Workflow de Infraestructura

El archivo `.github/workflows/infrastructure.yml` automatiza:

1. **Validación** de código Terraform
2. **Plan** para Pull Requests
3. **Apply** automático en main branch
4. **Export** de outputs para otros workflows

### Outputs Disponibles

Después de aplicar Terraform, estos valores están disponibles:

```bash
# Información del ACR
terraform output acr_name
terraform output acr_login_server
terraform output acr_admin_username
terraform output acr_admin_password

# URLs de los servicios
terraform output frontend_url
terraform output auth_api_url
terraform output users_api_url
terraform output todos_api_url

# Nombres para deployment
terraform output auth_api_name
terraform output users_api_name
terraform output todos_api_name
terraform output log_processor_name
terraform output frontend_name
```

## 🛡️ Seguridad

### Implementado
- ✅ **Key Vault** para secretos
- ✅ **Managed Identity** para App Services
- ✅ **NSG** para control de red
- ✅ **TLS 1.2** mínimo para Redis
- ✅ **HTTPS** forzado para App Services
- ✅ **Admin ACR** solo para CI/CD

### Para Producción
- 🔴 **Cambiar allowed_ips** por IPs específicas
- 🔴 **Usar Managed Identity** en lugar de admin ACR
- 🔴 **Habilitar Application Insights**
- 🔴 **Configurar Private Endpoints**

## 💰 Optimización de Costos

### Configuración Actual (Desarrollo)
- **App Service Plan**: B1 (Basic)
- **Redis**: Basic C0
- **ACR**: Standard

### Para Producción
- **App Service Plan**: P1V2 o superior
- **Redis**: Standard o Premium
- **ACR**: Premium (para geo-replicación)

## 📊 Monitoreo

### Disponible
- **Azure Monitor** habilitado
- **Application Insights** (configurar después)
- **Log Analytics** (configurar después)

### Tags para Seguimiento
Todos los recursos incluyen tags:
```hcl
Project     = "microservice-todo-app"
Environment = var.environment
ManagedBy   = "terraform"
```

## 🔧 Comandos Útiles

```bash
# Ver estado actual
terraform show

# Ver outputs
terraform output

# Destruir infraestructura (¡CUIDADO!)
terraform destroy

# Formatear código
terraform fmt

# Validar sintaxis
terraform validate

# Actualizar providers
terraform init -upgrade
```

## 🐛 Troubleshooting

### Error: "Storage account name already exists"
- El script `setup-terraform-backend.sh` genera nombres únicos automáticamente

### Error: "Insufficient permissions"
- Verifica que el Service Principal tenga rol "Contributor"

### Error: "Backend configuration changed"
- Ejecuta `terraform init -reconfigure`

### Error: "Key Vault access denied"
- Los permisos se configuran automáticamente via Managed Identity

## 📁 Estructura de Archivos

```
terraform/
├── main.tf                 # Configuración principal
├── variables.tf            # Variables de entrada
├── outputs.tf             # Valores de salida
├── resource-group.tf      # Grupo de recursos
├── network.tf             # Redes y seguridad
├── acr.tf                 # Container Registry
├── app-service-plan.tf    # Plan de App Service
├── app-services.tf        # App Services individuales
├── redis.tf               # Redis Cache
├── key-vault.tf           # Key Vault y secretos
├── terraform.tfvars.example # Ejemplo de variables
└── .gitignore             # Archivos ignorados

.github/workflows/
└── infrastructure.yml     # Workflow de CI/CD

scripts/
└── setup-terraform-backend.sh # Setup inicial
```

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

---

**¿Necesitas ayuda?** Abre un issue en GitHub o consulta la documentación de Azure y Terraform.