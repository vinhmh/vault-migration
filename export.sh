#!/bin/bash

OLD_VAULT_ADDR="http://127.0.0.1:8200"
OLD_VAULT_TOKEN="root-token"
SECRET_PATH="secret"

mkdir -p export

# List keys from old Vault
keys=$(curl -s \
  -H "X-Vault-Token: $OLD_VAULT_TOKEN" \
  -X LIST "$OLD_VAULT_ADDR/v1/$SECRET_PATH/metadata" \
  | jq -r '.data.keys[]?')

for key in $keys; do
  echo "📤 Exporting: $key"

  # Read each secret
  response=$(curl -s \
    -H "X-Vault-Token: $OLD_VAULT_TOKEN" \
    "$OLD_VAULT_ADDR/v1/$SECRET_PATH/data/$key")

  # Save just the secret data part
  echo "$response" | jq '.data.data' > "export/${key}.json"
done
