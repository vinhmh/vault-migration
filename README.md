# Vault Setup and Migration Guide

> **⚠️ WARNING**: Do not run `docker compose down` during migration as it will stop the vault containers and potentially lose data.

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

## 🔧 Environment Configuration

After setting up your vault, update API, Jobs environment variables:

```bash
# For jobs, API
VAULT_URL='http://vault-prod:8200'
VAULT_TOKEN='YOUR_NEW_VAULT_TOKEN'
```

**Note**: Replace `YOUR_NEW_VAULT_TOKEN` with the actual root token from your vault initialization.

## 🔄 Migration Process

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

## 🔑 Auto Unseal on Restart (Scripted Method)

This project uses a startup script to automatically unseal Vault after a restart, using unseal keys stored in a file.

### How It Works

- The `vault-entrypoint.sh` script is set as the entrypoint for the `vault-prod` container.
- To set up the scripted auto-unseal:
  1. Prepare `vault.dockerfile` ([see here](https://github.com/vinhmh/vault-migration/blob/main/vault.dockerfile)).
  2. Prepare `vault-entrypoint.sh` ([see here](https://github.com/vinhmh/vault-migration/blob/main/vault-entrypoint.sh)).
  3. Prepare `unseal-keys.txt` (enter your 3 unseal keys) ([see here](https://github.com/vinhmh/vault-migration/blob/main/unseal-keys.txt)).
  4. Build your custom Vault image:
     ```bash
     docker build -t custom-vault:latest -f vault.dockerfile ./
     ```
  5. Update your Docker Compose file (see [docker-compose.yaml](https://github.com/vinhmh/vault-migration/blob/main/docker-compose.yaml#L17C1-L31C3)).
  6. Restart your Docker Compose services:
     ```bash
     docker compose up -d vault-prod
     ```
  7. Vault will be automatically unsealed and ready for use.

### File Locations

- **Unseal keys:**  
  `unseal-keys.txt` (mounted to `/vault/keys/unseal-keys.txt` in the container)
- **Entrypoint script:**  
  `vault-entrypoint.sh` (mounted to `/vault-entrypoint.sh` in the container)

### Security Note

> **Warning:**  
> Storing unseal keys in a file is not recommended for production environments. For higher security, use Vault's [Auto Unseal with a KMS provider](https://www.vaultproject.io/docs/concepts/seal#auto-unseal) (see below).

---

#### (Optional) KMS-Based Auto Unseal

For production, consider configuring Vault to use a cloud KMS (AWS, GCP, Azure, etc.) for auto-unseal. This removes the need to store unseal keys and improves security. See the "Setting Up Auto Unseal on Restart" section above for details.

## 📚 Additional Resources

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Vault CLI Reference](https://www.vaultproject.io/docs/commands)