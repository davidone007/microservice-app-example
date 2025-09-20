#!/bin/bash

# ADVERTENCIA: Este script eliminará de forma permanente toda la infraestructura de Azure creada.
# Úsalo con precaución.

set -e

echo "Iniciando la eliminación de toda la infraestructura..."

# Purgar el Key Vault para permitir la eliminación inmediata del grupo de recursos
echo "Purgando el Key Vault 'microservices-kv-taller'..."
az keyvault purge --name microservices-kv-taller || echo "No se pudo purgar el Key Vault (puede que ya no exista)."

# Eliminar el grupo de recursos principal de la aplicación
echo "Eliminando el grupo de recursos 'microservices-rg'..."
az group delete --name microservices-rg --yes --no-wait

# Eliminar el grupo de recursos del backend de Terraform
echo "Eliminando el grupo de recursos 'tfstate-rg-microservices'..."
az group delete --name tfstate-rg-microservices --yes --no-wait

echo "Se han iniciado los procesos de eliminación. La eliminación completa puede tardar varios minutos."
echo "Puedes verificar el estado en el portal de Azure."