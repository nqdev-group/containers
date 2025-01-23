#!/bin/sh
# vim:sw=4:ts=4:et

set -e
ME=$(basename "$0")

# Định nghĩa hàm entrypoint_log để ghi log
entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  fi
}

# Kiểm tra biến CRONTAB_ENABLE
if [ "$CRONTAB_ENABLE" = "true" ]; then
  entrypoint_log "$ME: Starting crontab on daemon."
    
  # Khởi động crond (cron daemon) ở chế độ nền
  crond -b
else
  entrypoint_log "$ME: Crontab is disabled. Set CRONTAB_ENABLE=true to enable it."
fi

exit 0
