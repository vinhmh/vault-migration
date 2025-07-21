FROM hashicorp/vault:latest

# Copy your custom config and unseal script
COPY vault-config.hcl /vault/config/vault-config.hcl
COPY vault-entrypoint.sh /usr/local/bin/vault-entrypoint.sh
COPY unseal-keys.txt /vault/keys/unseal-keys.txt

# Make entrypoint executable
RUN chmod +x /usr/local/bin/vault-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/vault-entrypoint.sh"]
