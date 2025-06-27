#!/bin/bash

NEW_VAULT_ADDR="http://127.0.0.1:8201"
NEW_VAULT_TOKEN="YOUR_NEW_VAULT_TOKEN"
SECRET_PATH="secret"

echo "📥 Starting import to $NEW_VAULT_ADDR..."

for file in export/*.json; do
  key=$(basename "$file" .json)
  data=$(cat "$file")

  echo "🔁 Importing key: $key"

  curl -s --request POST \
    --header "X-Vault-Token: $NEW_VAULT_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"data\": $data}" \
    "$NEW_VAULT_ADDR/v1/$SECRET_PATH/data/$key"

  echo "✅ Imported: $key"
done

echo "🏁 Import complete."
