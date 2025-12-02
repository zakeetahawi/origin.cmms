# Atlas CMMS Backup and Restore Guide

This document provides instructions for backing up and restoring your Atlas CMMS system using the provided utility scripts. The utilities are available for both Windows and Linux operating systems.

## Prerequisites

- Docker and Docker Compose installed and running
- Atlas CMMS system up and running
- Administrative access to your system

## Windows Instructions

### Setup

1. Save the [atlas-backup.ps1](../scripts/backup/atlas-backup.ps1) script to your Atlas CMMS project directory
2. Open PowerShell as Administrator
3. Navigate to your Atlas CMMS project directory:
   ```powershell
   cd C:\path\to\your\atlas\project
   ```
4. Ensure script execution is allowed:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   ```

### Creating a Backup

To create a complete backup of your Atlas CMMS system:

```powershell
.\atlas-backup.ps1 backup
```

The script will:
1. Check if Docker is running
2. Back up the PostgreSQL database
3. Back up the MinIO file storage
4. Create a ZIP archive in the `atlas_backups` directory

#### Optional Parameters

To skip backing up the database:
```powershell
.\atlas-backup.ps1 backup -SkipDb
```

To skip backing up the files:
```powershell
.\atlas-backup.ps1 backup -SkipFiles
```

### Restoring from a Backup
Ensure the backend container is stopped.
To restore your Atlas CMMS system from a backup:

```powershell
.\atlas-backup.ps1 restore .\atlas_backups\atlas_backup_YYYYMMDD_HHMMSS.zip
```

Replace `YYYYMMDD_HHMMSS` with the timestamp of your backup file.

#### Optional Parameters

To skip restoring the database:
```powershell
.\atlas-backup.ps1 restore .\atlas_backups\atlas_backup_YYYYMMDD_HHMMSS.zip -SkipDb
```

To skip restoring the files:
```powershell
.\atlas-backup.ps1 restore .\atlas_backups\atlas_backup_YYYYMMDD_HHMMSS.zip -SkipFiles
```

## Linux Instructions

### Setup

1. Save the [atlas-backup.sh](../scripts/backup/atlas-backup.sh) script to your Atlas CMMS project directory
2. Open a terminal
3. Navigate to your Atlas CMMS project directory:
   ```bash
   cd /path/to/your/atlas/project
   ```
4. Make the script executable:
   ```bash
   chmod +x atlas-backup.sh
   ```

### Creating a Backup

To create a complete backup of your Atlas CMMS system:

```bash
./atlas-backup.sh backup
```

The script will:
1. Check if Docker is running
2. Back up the PostgresSQL database
3. Back up the MinIO file storage
4. Create a tar.gz archive in the `atlas_backups` directory

#### Optional Parameters

To skip backing up the database:
```bash
./atlas-backup.sh backup --skip-db
```

To skip backing up the files:
```bash
./atlas-backup.sh backup --skip-files
```

### Restoring from a Backup
Ensure the backend container is stopped.
To restore your Atlas CMMS system from a backup:

```bash
./atlas-backup.sh restore ./atlas_backups/atlas_backup_YYYYMMDD_HHMMSS.tar.gz
```

Replace `YYYYMMDD_HHMMSS` with the timestamp of your backup file.

#### Optional Parameters

To skip restoring the database:
```bash
./atlas-backup.sh restore ./atlas_backups/atlas_backup_YYYYMMDD_HHMMSS.tar.gz --skip-db
```

To skip restoring the files:
```bash
./atlas-backup.sh restore ./atlas_backups/atlas_backup_YYYYMMDD_HHMMSS.tar.gz --skip-files
```

## Environment Configuration

Both scripts automatically read credentials from a `.env` file in the same directory. If your Atlas CMMS uses custom credentials, make sure your `.env` file contains the following variables:

```
POSTGRES_USER=your_postgres_username
POSTGRES_PWD=your_postgres_password
MINIO_USER=your_minio_username
MINIO_PASSWORD=your_minio_password
```

If the `.env` file is not present, the scripts will use default credentials:

## Important Notes

1. **Database Restoration**: When restoring a database, the script renames your current database to `atlas_old` before creating a new `atlas` database with the backup data. This allows for recovery if the restore process fails.

2. **Confirmation Prompts**: The restore operation will prompt for confirmation before overwriting your database or files.

3. **Backup Directory**: All backups are stored in an `atlas_backups` directory created in the same location as the script.

4. **Network Configuration**: The scripts assume your Docker Compose network is named `atlas-cmms_default`. If your setup uses a different network name, you'll need to modify the scripts accordingly.

## Troubleshooting

### Docker Not Running

If you receive an error about Docker not running, ensure Docker Desktop (Windows) or Docker service (Linux) is started:

- Windows: Open Docker Desktop application
- Linux: Run `sudo systemctl start docker`

### Container Not Found

If you see errors about containers not being found, ensure your Atlas CMMS environment is running:

```bash
docker-compose ps  # Check if containers are running
docker-compose up -d  # Start containers if needed
```

### Permission Denied (Linux)

If you encounter permission errors on Linux, make sure the script is executable:

```bash
chmod +x atlas-backup.sh
```

### Network Issues

If the script cannot connect to containers, verify your Docker network configuration:

```bash
docker network ls
```

If your Atlas CMMS network is not named `atlas-cmms_default`, you'll need to update the network name in the scripts.