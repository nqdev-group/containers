#!/bin/sh

# Định nghĩa thư mục sao lưu
BACKUP_DIR="/var/backups/nginx_config"
DATE=$(date +\%Y\%m\%d)  # Lấy ngày hiện tại
TIME=$(date "+%Y-%m-%d %H:%M:%S")  # Timestamp cho log
NGINX_CONFIG_DIR="/etc/nginx"
LOG_FILE="/var/log/nginx/nginx_backup.log"
ME=$(basename "$0")

# Định nghĩa hàm entrypoint_log để ghi log
entrypoint_log() {
  if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    echo "$@"
  fi
}

# Tạo thư mục sao lưu nếu không có
mkdir -p $BACKUP_DIR

# Sao lưu file cấu hình Nginx
# cp -r $NGINX_CONFIG_DIR $BACKUP_DIR/nginx_config_$DATE

# Nén sao lưu cấu hình Nginx vào thư mục sao lưu dưới dạng .tar.gz
if tar -czf $BACKUP_DIR/nginx_config_$DATE.tar.gz -C $NGINX_CONFIG_DIR .; then
  # Ghi log sao lưu
  entrypoint_log "$TIME - Backup Nginx configuration completed on $DATE => $BACKUP_DIR/nginx_config_$DATE.tar.gz" | tee -a $LOG_FILE
else
  entrypoint_log "$TIME - Error occurred during backup." | tee -a $LOG_FILE
  exit 1
fi

# Xóa các file sao lưu cũ hơn 30 ngày
find $BACKUP_DIR -type f -mtime +30 -exec rm -f {} \;

# Ghi log xóa các file cũ
entrypoint_log "$TIME - Deleted backups older than 30 days on $DATE" | tee -a $LOG_FILE

exit 0
