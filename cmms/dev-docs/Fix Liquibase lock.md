# Fixing Liquibase "Waiting for changelog lock" Error

If you encounter the following error when using Liquibase:

```
Waiting for changelog lock....
```

It means the `DATABASECHANGELOGLOCK` table is locked, usually due to an interrupted or failed Liquibase process.

## Solution: Manually Release the Lock

You can manually unlock the database by running the following SQL command:

```sql
UPDATE DATABASECHANGELOGLOCK
SET LOCKED = FALSE,
    LOCKGRANTED = NULL,
    LOCKEDBY = NULL
WHERE ID = 1;
```

## How to Execute

```bash
docker exec -i atlas_db psql -U $POSTGRES_USER -d atlas -c "UPDATE DATABASECHANGELOGLOCK SET LOCKED=false, LOCKGRANTED=null, LOCKEDBY=null WHERE ID=1;"
```

Replace `$POSTGRES_USER` with your actual username if not using environment variables.

## Verification

You can verify that the lock was released by running:

```bash
docker exec -i atlas_db psql -U $POSTGRES_USER -d atlas -c "SELECT * FROM DATABASECHANGELOGLOCK;"
```

The output should show `LOCKED = false`.

---

**Note:** Only use this method when you're sure no other Liquibase processes are running. Manually unlocking without confirming this can lead to race conditions or corruption in the changelog.