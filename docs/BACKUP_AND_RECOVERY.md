# HostelEase — Backup & Disaster Recovery Guide

## 1. Automated PostgreSQL Backup Strategy
Production installations must schedule daily automated dumps using `pg_dump`.

### Backup Shell Script (`backup.sh`):
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/hostelease"
DATE=$(date +"%Y%m%d_%H%M%S")
FILENAME="$BACKUP_DIR/hostelease_db_$DATE.sql.gz"

mkdir -p $BACKUP_DIR
PGPASSWORD="$DB_PASSWORD" pg_dump -h localhost -p 5432 -U hostelease_app -F p hostelease_db | gzip > $FILENAME

# Retain backups for 30 days
find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +30 -delete
echo "[$(date)] Backup completed: $FILENAME"
```

---

## 2. Recovery Procedure
To restore the database from a backup archive:
```bash
# 1. Terminate existing connections
psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'hostelease_db' AND pid <> pg_backend_pid();"

# 2. Decompress and restore
gunzip -c /var/backups/hostelease/hostelease_db_YYYYMMDD_HHMMSS.sql.gz | psql -U hostelease_app -d hostelease_db
```
---

## 3. Disaster Recovery RTO & RPO Targets
- **Recovery Point Objective (RPO)**: < 24 hours (with daily full dumps) or < 15 minutes (with PostgreSQL WAL archiving).
- **Recovery Time Objective (RTO)**: < 30 minutes to restore WAR and database on a standby Tomcat instance.
