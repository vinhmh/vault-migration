#!/bin/sh

# Fix permission if needed
chown -R vault:vault /vault/data

# Start Vault server in background
vault server -config=/vault/config/vault-config.hcl &
VAULT_PID=$!

# Wait for Vault API to be available
echo "⏳ Waiting for Vault to start..."
sleep 5

export VAULT_ADDR=http://0.0.0.0:8200

# Loop to ensure Vault is responding
# until curl -s $VAULT_ADDR/v1/sys/health > /dev/null; do
#   echo "Vault not ready yet..." 
#   sleep 2
# done

# Unseal using stored keys
if vault status | grep -q 'Sealed.*true'; then
  echo "🔐 Vault is sealed, unsealing now..."
  for key in $(cat /vault/keys/unseal-keys.txt); do
    vault operator unseal "$key"
  done
else
  echo "✅ Vault is already unsealed."
fi

# Wait for Vault process to exit
wait $VAULT_PID
