# Vault Setup and Migration Guide

> **⚠️ WARNING**: Do not run `docker compose down` during migration as it will stop the vault containers and potentially lose data. Use `docker compose stop` instead if you need to pause the services temporarily.

This guide provides step-by-step instructions for setting up HashiCorp Vault and migrating data between vault instances.

## 📋 Prerequisites

Before starting, ensure you have:
- Docker and Docker Compose installed
- Updated `docker-compose.yml` and `vault-config.hcl` files

### Docker Compose Configuration

Make sure your `docker-compose.yml` includes the `vault-prod` service:

```yaml
vault-prod:
  image: hashicorp/vault:latest
  ports:
    - "8201:8200"
  volumes:
    - vault-prod-data:/vault/data        # Volume contains secrets
    - ./vault-config.hcl:/vault/config/vault-config.hcl
  cap_add:
    - IPC_LOCK
  environment:
    VAULT_ADDR: http://0.0.0.0:8200
  command: >
    sh -c "chown -R 100:100 /vault/data && vault server -config=/vault/config/vault-config.hcl"
```

**Important**: Don't forget to include the `vault-prod-data` volume in your volumes section.

For the `vault-config.hcl` configuration, please refer to the [vault-config.hcl file](https://github.com/vinhmh/vault-migration/blob/main/vault-config.hcl) in this repository.

Start the vault container:

```bash
docker compose up -d vault-prod
```

## 🚀 Initial Setup

### 1. Initialize Vault

Access the new vault container and initialize it:

```bash
vault operator init
```

> **⚠️ WARNING**: You need to save the unseal keys. If lost, you will lose all secret keys.

#### Example Output

```bash
vault operator init
Unseal Key 1: PeUpMVBpibrFBjyMYktgvhIGs99p8ixy7+f67AMhYAtw
Unseal Key 2: bXCpbGyKm+c7lbheWB5yG0HB2bcHMWSK6TWNAO+QJfwy
Unseal Key 3: Kg78mxN9I8BJyxGLOE1UUGt3Q5AEbX9ftQdDhrG70oeX
Unseal Key 4: 9/S3dF7R5ryPFNGkcx6+ygWBPIihkhbImrPjdfrVLwX9
Unseal Key 5: DCIDlCihcfuWROq16R2slUWIUPfBHtRECUasGBmxR694

Initial Root Token: hvs.YOUR_ACTUAL_TOKEN_HERE
```

### 2. Unseal Vault

Run the unseal command 3 times, each time with a different unseal key:

```bash
vault operator unseal
```

### 3. Login and Configure

After successful unsealing:

1. **Login with Root Token**:
   ```bash
   vault login
   ```

2. **Enable KV Secrets Engine**:
   ```bash
   vault secrets enable -path=secret --version=2 kv
   ```

## 🔄 Migration Process

### 1. Exit Container

Exit the vault container after configuration.

### 2. Prepare Migration

**Step 1: Export data from old vault**
```bash
sh export.sh
```

**Step 2: Import data to new vault**
```bash
sh import.sh
```

## 📁 Project Files

| File | Description |
|------|-------------|
| `docker-compose.yaml` | Docker Compose configuration |
| `vault-config.hcl` | Vault configuration file |
| `export.sh` | Export script for vault data |
| `import.sh` | Import script for vault data |

## 🔒 Security Notes

> **⚠️ Important**: Never commit actual Vault tokens or unseal keys to version control. Always use environment variables or secure secret management for production tokens.

## 📚 Additional Resources

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Vault CLI Reference](https://www.vaultproject.io/docs/commands)