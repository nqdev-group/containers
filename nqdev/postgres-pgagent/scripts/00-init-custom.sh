#!/bin/bash
set -e
ME=$(basename "$0")

# Định nghĩa hàm entrypoint_log để ghi log
entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  else
    echo "$@"
  fi
}

entrypoint_log "$ME: >> Running custom SQL init scripts..."

for f in /nqdev/postgres/docker-entrypoint-initdb.d/*.sql; do
  entrypoint_log "$ME: >> Executing $f"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
done

entrypoint_log "$ME: >> Custom SQL init scripts completed."
