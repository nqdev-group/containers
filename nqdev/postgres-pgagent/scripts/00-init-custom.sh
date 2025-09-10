#!/usr/bin/env bash
set -Eeo pipefail
ME=$(basename "$0")

# Định nghĩa hàm entrypoint_log để ghi log
entrypoint_log() {
  echo "$ME: >> $@"
}

# Hàm xử lý lỗi toàn cục (mô phỏng catch)
handle_error() {
  local exit_code=$?
  local line_number=$1
  entrypoint_log "❌ ERROR at line $line_number with exit code $exit_code"
  exit $exit_code
}

# Bắt lỗi toàn cục
trap 'handle_error $LINENO' ERR

entrypoint_log "Running custom SQL init scripts..."

for f in /nqdev/postgres/docker-entrypoint-initdb.d/*.sql; do
  entrypoint_log "Executing $f"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
done

for f in /nqdev/postgres/docker-entrypoint-initdb.d/*.sql; do
  if [[ -f "$f" ]]; then
    entrypoint_log "Executing $f"
    # "try" thực hiện lệnh psql, "catch" xử lý lỗi (bắt bởi trap)
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
    entrypoint_log "✅ Done $f"
  fi
done

entrypoint_log "Custom SQL init scripts completed."
