#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Despliegue automatizado: Terraform base-infrastructure"

# Basic checks
if ! command -v terraform >/dev/null 2>&1; then
  echo "❌ Terraform no está instalado. Instálalo e inténtalo otra vez." >&2
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "❌ Azure CLI (az) no está instalado. Instálalo e inténtalo otra vez." >&2
  exit 1
fi

# Check Azure login
if ! az account show >/dev/null 2>&1; then
  echo "❌ No estás autenticado en Azure. Ejecuta 'az login' y vuelve a intentarlo." >&2
  exit 1
fi

echo "✅ Verificaciones previas OK"

# Module selector (default to base-infrastructure)
TF_MODULE="${TF_MODULE:-base-infrastructure}"
TF_DIR="$(dirname "$0")/../$TF_MODULE"
TF_DIR_ABS=$(cd "$TF_DIR" && pwd)

echo "📁 Directorio objetivo: $TF_DIR_ABS"
cd "$TF_DIR_ABS"

RESOURCE_GROUP="microservices-rg"
LOCATION="centralus"
ACR_NAME="microservicesacr20250920"
KEY_VAULT_NAME="msapp-kv-20250920"
LOG_ANALYTICS_NAME="microservices-log-analytics"

echo "📦 Inicializando Terraform en $TF_DIR_ABS..."
terraform init

echo "📋 Creando plan de Terraform..."
terraform plan -out=tfplan -input=false \
  -var="resource_group_name=$RESOURCE_GROUP" \
  -var="location=$LOCATION" \
  -var="acr_name=$ACR_NAME" \
  -var="key_vault_name=$KEY_VAULT_NAME" \
  -var="log_analytics_name=$LOG_ANALYTICS_NAME"

echo "🔨 Aplicando plan..."
terraform apply -input=false -auto-approve tfplan

echo -e "\n🎉 Despliegue de base-infrastructure completado. Outputs:\n"
if command -v jq >/dev/null 2>&1; then
  terraform output -json | jq
else
  echo "(jq no está instalado — mostrando terraform output en texto plano)"
  terraform output
fi

cat <<'EOF'

Siguientes pasos recomendados:
 - Usa los outputs (acr_login_server, key_vault_uri, etc.) para configurar y desplegar las aplicaciones.
 - Mantén los secretos sensibles fuera del repo, usa GitHub Secrets si los necesitas en el pipeline.

EOF
