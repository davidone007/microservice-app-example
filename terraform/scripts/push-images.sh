#!/bin/bash

# Salir si un comando falla
set -e

# --- Configuración ---
# El servidor de login de ACR es una salida de la Fase 1 de Terraform.
# Puedes obtenerlo con: terraform output -state=../base-infrastructure/terraform.tfstate acr_login_server
ACR_LOGIN_SERVER="microservicesacr20250920.azurecr.io"

# Lista de servicios a construir y subir. Los nombres de directorio deben coincidir.
SERVICES=("auth-api" "frontend" "log-message-processor" "todos-api" "users-api" "zipkin")

# --- Lógica del Script ---

# 1. Iniciar sesión en ACR
echo "Iniciando sesión en Azure Container Registry: $ACR_LOGIN_SERVER..."
az acr login --name $ACR_LOGIN_SERVER

# 2. Iterar, construir y subir cada imagen
for SERVICE in "${SERVICES[@]}"; do
  IMAGE_NAME="$ACR_LOGIN_SERVER/$SERVICE:latest"
  SERVICE_DIR="../../$SERVICE" # Ruta relativa desde la ubicación del script

  if [ -d "$SERVICE_DIR" ]; then
    echo "--------------------------------------------------"
    echo "Procesando servicio: $SERVICE"
    echo "Construyendo imagen: $IMAGE_NAME"
    
    # Construir la imagen de Docker
    docker build -t $IMAGE_NAME "$SERVICE_DIR"
    
    echo "Subiendo imagen: $IMAGE_NAME"
    # Subir la imagen a ACR
    docker push $IMAGE_NAME
    
    echo "Servicio $SERVICE procesado exitosamente."
    echo "--------------------------------------------------"
  else
    echo "ADVERTENCIA: No se encontró el directorio del servicio $SERVICE en $SERVICE_DIR. Saltando..."
  fi
done

echo "¡Todas las imágenes han sido construidas y subidas a ACR exitosamente!"
