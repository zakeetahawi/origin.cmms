
# 🧹 Resetting Origin CMMS Database and MinIO Data

If you need to delete the existing PostgresSQL and MinIO data for a fresh start, follow this step-by-step guide.

> ⚠️ This will **permanently delete** all database and file storage data. Proceed with caution.

---

## 📁 Step 1: Stop and Remove Containers

Shut down all running containers related to Origin CMMS:

```bash
docker compose down
```

---

## 🗑️ Step 2: Remove Docker Volumes

Origin CMMS uses named Docker volumes for data persistence:
- `origin-cmms_postgres_data` for PostgreSQL
- `origin-cmms_minio_data` for MinIO

Delete them with:

```bash
docker volume rm origin-cmms_postgres_data origin-cmms_minio_data
```

## 🚀 Step 4: Restart Origin CMMS

Recreate containers and volumes with fresh data:

```bash
docker compose up -d
```

---

## ✅ Result

You now have:
- A fresh PostgreSQL database (`POSTGRES_DB`)
- An empty MinIO bucket
- Origin CMMS services running on a clean slate