#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 -g <resource-group> -d <terraform-dir> [-n] [-y]

Example:
  # From repo root, interactive mode
  ./terraform/scripts/import-container-apps.sh -g microservices-rg -d terraform/container-apps

  # Dry-run to preview commands
  ./terraform/scripts/import-container-apps.sh -g microservices-rg -d terraform/container-apps -n

  # Non-interactive for automation
  ./terraform/scripts/import-container-apps.sh -g microservices-rg -d terraform/container-apps -y

This script lists Container Apps in a specified resource group and imports them into the Terraform state.
It maps the Azure resource name to the corresponding Terraform module name (e.g., 'users-api' becomes 'users_api').
EOF
}

RG=""
TF_DIR=""
DRY_RUN=0
ASSUME_YES=0

while getopts ":g:d:nyh" opt; do
  case ${opt} in
    g ) RG=$OPTARG ;;
    d ) TF_DIR=$OPTARG ;;
    n ) DRY_RUN=1 ;;
    y ) ASSUME_YES=1 ;;
    h ) usage; exit 0 ;;
    \? ) echo "Invalid option: -$OPTARG"; usage; exit 1 ;;
  esac
done

if [ -z "$RG" ] || [ -z "$TF_DIR" ]; then
  usage
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Error: az CLI is required but not found." >&2
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "Error: terraform CLI is required but not found." >&2
  exit 1
fi

echo "Listing Container Apps in resource group: $RG"
# Get a tab-separated list of app names and their IDs
APPS_TSV=$(az containerapp list --resource-group "$RG" --query "[].[name,id]" -o tsv)

if [ -z "$APPS_TSV" ]; then
  echo "No Container Apps found in resource group '$RG'."
  exit 0
fi

echo "Found the following Container Apps:"
echo "$APPS_TSV" | awk '{print $1}'

if [ "$ASSUME_YES" -ne 1 ]; then
  read -p "Proceed to import these Container Apps into Terraform state in directory '$TF_DIR'? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted by user."
    exit 1
  fi
else
  echo "Auto-confirm enabled (-y): proceeding without prompt."
fi

# Resolve terraform directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"

if [ -d "$TF_DIR" ]; then
  TARGET_TF_DIR="$(cd "$TF_DIR" && pwd)"
elif [ -d "$repo_root/$TF_DIR" ]; then
  TARGET_TF_DIR="$repo_root/$TF_DIR"
else
  echo "Terraform directory '$TF_DIR' not found." >&2
  exit 1
fi

pushd "$TARGET_TF_DIR" >/dev/null

echo "$APPS_TSV" | while read -r app_name app_id; do
  if [ -z "$app_name" ]; then
    continue
  fi

  # Clean up carriage returns from the ID, which can be an issue in Git Bash on Windows
  app_id_clean=$(echo "$app_id" | tr -d '\r')

  # Fix the casing of 'containerApps' in the resource ID for Terraform provider compatibility
  app_id_fixed_case=$(echo "$app_id_clean" | sed 's|/containerapps/|/containerApps/|')

  # Convert app name to module name (e.g., 'users-api' -> 'users_api')
  module_name=$(echo "$app_name" | tr '-' '_')
  
  tf_address="module.${module_name}.azurerm_container_app.main"
  
  # The 'MSYS_NO_PATHCONV=1' prefix prevents Git Bash from converting the Azure resource ID
  printf 'Command: MSYS_NO_PATHCONV=1 terraform import "%s" "%s"\n' "$tf_address" "$app_id_fixed_case"

  if [ "$DRY_RUN" -eq 0 ]; then
    printf 'Importing %s -> %s\n' "$app_id_fixed_case" "$tf_address"
    MSYS_NO_PATHCONV=1 terraform import "$tf_address" "$app_id_fixed_case"
  else
    echo "Dry-run: skipping execution."
  fi
done

echo "Imports finished. Run 'terraform plan' to verify." 
popd >/dev/null
