
# 🧹 Resetting Atlas CMMS Database and MinIO Data

If you need to delete the existing PostgresSQL and MinIO data for a fresh start, follow this step-by-step guide.

> ⚠️ This will **permanently delete** all database and file storage data. Proceed with caution.

---

## 📁 Step 1: Stop and Remove Containers

Shut down all running containers related to Atlas CMMS:

```bash
docker compose down
```

---

## 🗑️ Step 2: Remove Docker Volumes

Atlas CMMS uses named Docker volumes for data persistence:
- `atlas-cmms_postgres_data` for PostgreSQL
- `atlas-cmms_minio_data` for MinIO

Delete them with:

```bash
docker volume rm atlas-cmms_postgres_data atlas-cmms_minio_data
```

## 🚀 Step 4: Restart Atlas CMMS

Recreate containers and volumes with fresh data:

```bash
docker compose up -d
```

---

## ✅ Result

You now have:
- A fresh PostgreSQL database (`POSTGRES_DB`)
- An empty MinIO bucket
- Atlas CMMS services running on a clean slate