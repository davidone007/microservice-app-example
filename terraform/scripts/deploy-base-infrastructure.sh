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

# Detect var-file (priority: TF_VAR_FILE env, CLI arg, module-local terraform.tfvars)
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
  echo "❗ No se encontró archivo de variables. Para valores sensibles (db password, jwt secret) crea 'terraform.tfvars' en el módulo o usa TF_VAR_FILE." >&2
  exit 1
fi

echo "📦 Inicializando Terraform en $TF_DIR_ABS..."
terraform init

echo "📋 Creando plan de Terraform..."
terraform plan -out=tfplan -input=false $VAR_FILE_ARG

echo "🔨 Aplicando plan..."
terraform apply -input=false -auto-approve tfplan

echo "\n🎉 Despliegue de base-infrastructure completado. Outputs:\n"
if command -v jq >/dev/null 2>&1; then
  terraform output -json | jq
else
  echo "(jq no está instalado — mostrando terraform output en texto plano)"
  terraform output
fi

cat <<'EOF'

Siguientes pasos recomendados:
 - Usa los outputs (acr_login_server, key_vault_uri, etc.) para configurar y desplegar las aplicaciones.
 - Para seguridad, no cometas el archivo 'terraform.tfvars' que contiene secretos.

EOF
