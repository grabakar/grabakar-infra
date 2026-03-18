#!/usr/bin/env bash
set -euo pipefail

# Basic health checks for the free-tier state VM containers.
# Intended for cron, e.g.:
#   */5 * * * * /home/<user>/grabakar-infra/scripts/vm_health_check.sh >> /var/log/grabakar-vm-health.log 2>&1

log() {
  echo "[$(date -Iseconds)] $*"
}

restart_if_down() {
  local container_name="$1"
  local check_cmd="$2"

  if ! docker exec "$container_name" bash -lc "$check_cmd" >/dev/null 2>&1; then
    log "UNHEALTHY: $container_name -> restarting"
    docker restart "$container_name" >/dev/null 2>&1 || true
  else
    log "OK: $container_name"
  fi
}

log "VM health check starting"

# Postgres
restart_if_down "grabakar-postgres" "pg_isready -U grabakar"

# Redis
restart_if_down "grabakar-redis" "redis-cli ping"

# Celery worker (container may not be present on first boot)
CELERY_RUNNING_IDS="$(docker ps -q --filter "name=grabakar-celery-worker" --filter "status=running" || true)"
if [ -z "$CELERY_RUNNING_IDS" ]; then
  log "UNHEALTHY: grabakar-celery-worker not running -> restart/initial start required"
  # Restart only if the container exists; otherwise create/start should be handled by CD.
  if docker ps -a -q --filter "name=grabakar-celery-worker" >/dev/null 2>&1; then
    docker restart grabakar-celery-worker >/dev/null 2>&1 || true
  fi
else
  log "OK: grabakar-celery-worker running"
fi

log "VM health check finished"

