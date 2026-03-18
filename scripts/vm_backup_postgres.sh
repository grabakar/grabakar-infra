#!/usr/bin/env bash
set -euo pipefail

# Free-tier VM backup: dump Postgres from the running container and upload to GCS.
#
# Intended usage (cron on the VM):
#   0 3 * * * /home/<user>/grabakar-infra/scripts/vm_backup_postgres.sh
#
# Required on the VM:
# - docker running `grabakar-postgres`
# - gcloud auth configured for a service account that can write to the media bucket

log() {
  echo "[$(date -Iseconds)] $*"
}

POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-grabakar-postgres}"
DB_NAME="${DB_NAME:-grabakar}"
DB_USER="${DB_USER:-grabakar}"

# Example: gs://grabakar-media-staging/backups
GCS_BACKUP_PREFIX="${GCS_BACKUP_PREFIX:-gs://grabakar-media-staging/backups}"

BACKUP_KEEP_DAYS="${BACKUP_KEEP_DAYS:-7}"

TMP_FILE="/tmp/${DB_NAME}-backup-$(date +%Y%m%d).sql.gz"
OBJECT_NAME="$(basename "$TMP_FILE")"
DEST_URI="${GCS_BACKUP_PREFIX}/${OBJECT_NAME}"

log "Starting Postgres backup (container=${POSTGRES_CONTAINER}, db=${DB_NAME})"

# Dump directly from the container. The container already has POSTGRES_PASSWORD in its env.
docker exec "$POSTGRES_CONTAINER" bash -lc "pg_dump -U '$DB_USER' '$DB_NAME'" | gzip -c > "$TMP_FILE"

log "Uploading backup to: $DEST_URI"
gcloud storage cp "$TMP_FILE" "$DEST_URI"

rm -f "$TMP_FILE"

log "Applying retention policy (keep last ${BACKUP_KEEP_DAYS} days)"

# Delete backups older than KEEP_DAYS (based on filename YYYYMMDD).
NOW_EPOCH="$(date +%s)"

gcloud storage ls "${GCS_BACKUP_PREFIX}/" --format="value(name)" | while read -r full; do
  base="$(basename "$full")"
  # Expect: <db>-backup-YYYYMMDD.sql.gz
  date_part="$(echo "$base" | sed -E 's/.*-backup-([0-9]{8})\\.sql\\.gz/\\1/')"

  # Skip unexpected names
  if [[ ! "$date_part" =~ ^[0-9]{8}$ ]]; then
    continue
  fi

  backup_iso="${date_part:0:4}-${date_part:4:2}-${date_part:6:2}"
  backup_epoch="$(date -d "$backup_iso" +%s || true)"
  if [ -z "$backup_epoch" ]; then
    continue
  fi

  age_days="$(( (NOW_EPOCH - backup_epoch) / 86400 ))"
  if [ "$age_days" -gt "$BACKUP_KEEP_DAYS" ]; then
    log "Deleting old backup: $full (age=${age_days}d)"
    gcloud storage rm -q "$full"
  fi
done

log "Backup finished"

