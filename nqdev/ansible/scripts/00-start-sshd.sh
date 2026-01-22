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

# Bắt đầu khởi động SSHD
entrypoint_log "Starting SSHD service..."

# Đảm bảo SSHD được cấu hình đúng
if [ ! -f /etc/ssh/sshd_config ]; then
    entrypoint_log "sshd_config không tồn tại!"
    exit 1
fi

# Sinh password ngẫu nhiên nếu chưa có ADMIN_PASSWORD
if [ -z "${ADMIN_PASSWORD}" ]; then
  ADMIN_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)"
  echo "No ADMIN_PASSWORD env found. Generated random password for 'admin': ${ADMIN_PASSWORD}"
else
  echo "ADMIN_PASSWORD env found. Using provided password for 'admin'."
fi

# Đặt password cho user admin
echo "admin:${ADMIN_PASSWORD}" | chpasswd

# Optionally, tạo host key nếu chưa có (thường đây là best practice trong container)
/usr/bin/ssh-keygen -A

# In thông tin truy cập (nếu muốn)
entrypoint_log "SSH service is starting..."
entrypoint_log "----------------------------------"
entrypoint_log "You can connect via: ssh admin@<host> -p <port>"
entrypoint_log "Default password for 'admin': ${ADMIN_PASSWORD}"
entrypoint_log "----------------------------------"

# Khởi động Fail2ban service
entrypoint_log "Starting Fail2ban service..."
/etc/init.d/fail2ban start

# Khởi động sshd ở chế độ foreground
entrypoint_log "Executing sshd in foreground..."
exec /usr/sbin/sshd -D
