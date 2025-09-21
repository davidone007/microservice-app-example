#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 -v <vault-name> -d <terraform-dir> [-n] [-y]

Example:
  # from repo root, interactive (default)
  ./terraform/scripts/import-kv-secrets.sh -v msapp-kv-20250920 -d terraform/base-infrastructure

  # dry-run: print the terraform import commands but do not execute
  ./terraform/scripts/import-kv-secrets.sh -v msapp-kv-20250920 -d terraform/base-infrastructure -n

  # non-interactive: run imports without prompting
  ./terraform/scripts/import-kv-secrets.sh -v msapp-kv-20250920 -d terraform/base-infrastructure -y

This script will list secrets in the Key Vault and attempt to import them into
Terraform state using the address:
  module.key_vault.azurerm_key_vault_secret.main["<secret-name>"]

Options:
  -n  Dry-run mode. Print the import commands but do not execute them.
  -y  Assume yes: run imports without interactive confirmation.

It will only import secrets that exist in the vault. It prints each import command
before running (unless -n) and asks for confirmation (unless -y).
EOF
}

VAULT=""
TF_DIR=""
DRY_RUN=0
ASSUME_YES=0

while getopts ":v:d:nyh" opt; do
  case ${opt} in
    v ) VAULT=$OPTARG ;;
    d ) TF_DIR=$OPTARG ;;
    n ) DRY_RUN=1 ;;
    y ) ASSUME_YES=1 ;;
    h ) usage; exit 0 ;;
    \? ) echo "Invalid option: -$OPTARG"; usage; exit 1 ;;
  esac
done

if [ -z "$VAULT" ] || [ -z "$TF_DIR" ]; then
  usage
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "az CLI is required" >&2
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform CLI is required" >&2
  exit 1
fi

echo "Listing secrets in Key Vault: $VAULT"
SECRET_IDS=$(az keyvault secret list --vault-name "$VAULT" --query "[].id" -o tsv)

if [ -z "$SECRET_IDS" ]; then
  echo "No secrets found in vault $VAULT"
  exit 0
fi

echo "Found the following secrets (IDs):"
echo "$SECRET_IDS"

if [ "$ASSUME_YES" -ne 1 ]; then
  read -p "Proceed to import these secrets into Terraform state in directory '$TF_DIR'? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted by user"
    exit 1
  fi
else
  echo "Auto-confirm enabled (-y): proceeding without prompt"
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
  echo "Tried these locations:" >&2
  echo "  - $PWD/$TF_DIR" >&2
  echo "  - $repo_root/$TF_DIR" >&2
  exit 1
fi

pushd "$TARGET_TF_DIR" >/dev/null

for id in $SECRET_IDS; do
  # Normalize line endings (strip CR if present)
  id=$(echo "$id" | tr -d '\r')
  
  # Extract secret name from the URL using sed
  secret_name=$(echo "$id" | sed -E 's|.*/secrets/([^/]+)(/.*)?$|\1|' | tr -d '\r')
  echo "Debug: extracted secret name '$secret_name' from ID '$id'" >&2

  # Sanity check the extracted name
  if [[ "$secret_name" == "secrets" || -z "$secret_name" ]]; then
    echo "Error: Failed to extract valid secret name from ID '$id'" >&2
    exit 1
  fi

  # Try to obtain the full (versioned) secret ID
  versioned_id=$(az keyvault secret show --vault-name "$VAULT" --name "$secret_name" --query id -o tsv 2>/dev/null || echo "$id")
  versioned_id=$(echo "$versioned_id" | tr -d '\r')

  tf_address="module.key_vault.azurerm_key_vault_secret.main[\"$secret_name\"]"
  printf 'Command: terraform import "%s" "%s"\n' "$tf_address" "$versioned_id"

  if [ "$DRY_RUN" -eq 0 ]; then
    printf 'Importing %s -> %s\n' "$versioned_id" "$tf_address"
    terraform import "$tf_address" "$versioned_id"
  else
    echo "Dry-run: skipping execution"
  fi
done

echo "Imports finished. Run 'terraform plan' to verify." 
popd >/dev/null