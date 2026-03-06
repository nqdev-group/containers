#!/usr/bin/env bash
set -Eeo pipefail

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# docker-entrypoint-init.sh
# --------------------------
# Entrypoint wrapper cho PostgreSQL container.
# Xử lý vấn đề "wrong ownership" của data directory khi mount volume từ host.
#
# Vấn đề:
#   Khi mount volume từ host (ví dụ: ./data:/var/lib/postgresql/data),
#   thư mục trên host thường được tạo bởi root, trong khi PostgreSQL
#   cần chạy với user 'postgres' (UID 999) và yêu cầu ownership đúng.
#
# Giải pháp:
#   Script này chạy trước khi khởi động PostgreSQL, đảm bảo PGDATA
#   có ownership đúng (postgres:postgres) và permission phù hợp.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Lấy đường dẫn PGDATA, mặc định là /var/lib/postgresql/data
PGDATA="${PGDATA:-/var/lib/postgresql/data}"

# Chỉ thực hiện chown khi đang chạy với quyền root (uid=0)
# Điều này cho phép entrypoint script gốc sau đó drop xuống user 'postgres'
if [ "$(id -u)" = '0' ]; then
  # Tạo thư mục data nếu chưa tồn tại
  mkdir -p "$PGDATA"

  # Sửa ownership về postgres:postgres để tránh lỗi "wrong ownership"
  # Lỗi: FATAL: data directory has wrong ownership
  chown -R postgres:postgres "$PGDATA"

  # Đặt permission 0700 theo yêu cầu của PostgreSQL
  chmod 700 "$PGDATA"
fi

# Chuyển tiếp sang entrypoint chính của postgres image
exec /usr/local/bin/docker-entrypoint.sh "$@"
