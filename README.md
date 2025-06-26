# Vault Setup and Migration Guide

## Prerequisites

After updating `docker-compose.yml` and `vault-config.hcl`, start the vault container:

```bash
docker compose up -d vault-prod
```

## Initial Setup

### 1. Initialize Vault

Access the new vault container and initialize it:

```bash
vault operator init
```

**⚠️ WARNING**: You need to save the unseal keys. If lost, you will lose all secret keys.

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
   vault secrets enable -path=secret kv
   ```

## Migration Process

### 1. Exit Container

Exit the vault container after configuration.

### 2. Prepare Migration

Update the tokens of old and new servers in `migrate.sh` to prepare for migration:

```bash
sh migrate.sh
```

### 3. Data Migration

- **Export data from old vault**
- **Import data to new vault**

## Files

- `docker-compose.yaml` - Docker Compose configuration
- `vault-config.hcl` - Vault configuration file
- `migrate.sh` - Migration script
- `export.sh` - Export script
- `import.sh` - Import script

## Security Notes

⚠️ **Important**: Never commit actual Vault tokens or unseal keys to version control. Always use environment variables or secure secret management for production tokens. 