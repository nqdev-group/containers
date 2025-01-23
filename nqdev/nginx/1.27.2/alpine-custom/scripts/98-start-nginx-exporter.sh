#!/bin/sh

set -e
ME=$(basename "$0")

# Định nghĩa hàm entrypoint_log để ghi log
entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  fi
}

# Kiểm tra biến NGINX_EXPORTER_ENABLE
if [ "$NGINX_EXPORTER_ENABLE" = "true" ]; then
  entrypoint_log "$ME: Starting nginx-exporter on port $NGINX_EXPORTER_PORT..."
    
  # Chạy nginx-exporter với các tham số được lấy từ biến môi trường (ENV)
  /usr/local/bin/nginx-exporter \
    -nginx.scrape-uri=http://localhost:$NGINX_HTTP_PORT_NUMBER/nginx_status \
    -web.listen-address=:$NGINX_EXPORTER_PORT
else
  entrypoint_log "$ME: Nginx exporter is disabled. Set NGINX_EXPORTER_ENABLE=true to enable it."
fi

exit 0
