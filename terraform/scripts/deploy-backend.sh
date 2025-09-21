#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Despliegue automatizado: Terraform backend (Azure Storage)"

# Comprobaciones básicas
if ! command -v terraform >/dev/null 2>&1; then
  echo "❌ Terraform no está instalado. Instálalo e inténtalo otra vez." >&2
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "❌ Azure CLI (az) no está instalado. Instálalo e inténtalo otra vez." >&2
  exit 1
fi

# Comprobar login de Azure
if ! az account show >/dev/null 2>&1; then
  echo "❌ No estás autenticado en Azure. Ejecuta 'az login' y vuelve a intentarlo." >&2
  exit 1
fi

echo "✅ Verificaciones previas OK"

# Variables por defecto (puedes sobreescribir exportando antes)
TF_RG_DEFAULT="tfstate-rg-microservices"
TF_ST_ACCOUNT_DEFAULT="tfstatemsapp20250920ac"
TF_CONTAINER_DEFAULT="tfstate"
TF_KEY_DEFAULT="backend.terraform.tfstate"

# By default operate on the terraform-backend module, but allow selecting another module
# Set TF_MODULE to the relative module folder name (e.g. terraform-backend, base-infrastructure)
TF_MODULE="${TF_MODULE:-terraform-backend}"
TF_DIR="$(dirname "$0")/../$TF_MODULE"
TF_DIR_ABS=$(cd "$TF_DIR" && pwd)

echo "📁 Directorio objetivo: $TF_DIR_ABS"
cd "$TF_DIR_ABS"

# Mensaje sobre variables (si el usuario exportó variables las respetamos)
TF_RG="${TF_RG:-$TF_RG_DEFAULT}"
TF_ST_ACCOUNT="${TF_ST_ACCOUNT:-$TF_ST_ACCOUNT_DEFAULT}"
TF_CONTAINER="${TF_CONTAINER:-$TF_CONTAINER_DEFAULT}"
TF_KEY="${TF_KEY:-$TF_KEY_DEFAULT}"

echo "🔧 Usando configuración:
  Resource Group: $TF_RG
  Storage Account: $TF_ST_ACCOUNT
  Container: $TF_CONTAINER
  Key: $TF_KEY"


# Inicializar Terraform (no reconfiguramos backend aquí porque este módulo crea el backend)
echo "📦 Inicializando Terraform en $TF_DIR_ABS..."
terraform init

# Detectar archivo de variables (module-local terraform.tfvars) o variable de entorno TF_VAR_FILE
# Behavior priority:
# 1) If TF_VAR_FILE env var is set and points to a file, use it
# 2) Else if a file path was passed via CLI (first arg) and exists, use it
# 3) Else if a module-local terraform.tfvars exists, use it
# 4) Else fall back to using inline -var args
VAR_FILE_ARG=""
CLI_VARFILE_ARG="${1:-}"
if [ -n "${TF_VAR_FILE:-}" ] && [ -f "$TF_VAR_FILE" ]; then
  VAR_FILE_ARG="-var-file=$TF_VAR_FILE"
  echo "🔐 Usando archivo de variables desde TF_VAR_FILE: $TF_VAR_FILE"
elif [ -n "$CLI_VARFILE_ARG" ] && [ -f "$CLI_VARFILE_ARG" ]; then
  VAR_FILE_ARG="-var-file=$CLI_VARFILE_ARG"
  echo "🔐 Usando archivo de variables desde argumento: $CLI_VARFILE_ARG"
elif [ -f "terraform.tfvars" ]; then
  VAR_FILE_ARG="-var-file=terraform.tfvars"
  echo "🔐 Usando archivo de variables local del módulo: terraform.tfvars"
else
  echo "ℹ️  No se encontró terraform.tfvars en el módulo, pasando variables por linea de comandos (menos seguro)."
fi

# Crear plan
echo "📋 Creando plan de Terraform..."
if [ -n "$VAR_FILE_ARG" ]; then
  terraform plan -out=tfplan -input=false $VAR_FILE_ARG
else
  terraform plan -out=tfplan -input=false -var="resource_group_name=$TF_RG" -var="storage_account_name=$TF_ST_ACCOUNT" -var="container_name=$TF_CONTAINER" -var="key=$TF_KEY"
fi

# Aplicar
echo "🔨 Aplicando plan..."
if [ -n "$VAR_FILE_ARG" ]; then
  terraform apply -input=false -auto-approve tfplan
else
  terraform apply -input=false -auto-approve tfplan
fi

# Mostrar outputs
echo "\n🎉 Despliegue del backend completado. Outputs:\n"
if command -v jq >/dev/null 2>&1; then
  terraform output -json | jq
else
  echo "(jq no está instalado — mostrando terraform output en texto plano)"
  terraform output
fi

cat <<'EOF'

Siguientes pasos recomendados:
 - Usa los valores de output (storage_account_name, container_name, key) para configurar los backends de los demás módulos.
 - En cada carpeta de terraform (base-infrastructure, container-apps) ejecuta:
     terraform init
     terraform plan
     terraform apply -var="..."

EOF
