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
#   thư mục có thể được sở hữu bởi một UID khác (user host, NFS, rootless...).
#   PostgreSQL yêu cầu tiến trình phải chạy bởi user sở hữu data directory.
#   Trên một số filesystem (NFS squash_root, Docker Desktop, rootless container),
#   lệnh chown có thể không thực sự thay đổi ownership.
#
# Giải pháp:
#   Script phát hiện UID thực sự đang sở hữu PGDATA rồi khởi chạy PostgreSQL
#   bằng chính UID đó — tránh phụ thuộc vào chown.
#   - Nếu PGDATA do root (UID 0) sở hữu: chown sang postgres rồi để upstream xử lý.
#   - Nếu PGDATA do UID khác sở hữu: gosu sang UID đó, bỏ qua bước chown.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Lấy đường dẫn PGDATA, mặc định là /var/lib/postgresql/data
PGDATA="${PGDATA:-/var/lib/postgresql/data}"

if [ "$(id -u)" = '0' ]; then
  # Tạo thư mục data nếu chưa tồn tại
  mkdir -p "$PGDATA"

  # Đặt permission 0700 theo yêu cầu của PostgreSQL (non-fatal khi filesystem giới hạn)
  chmod 700 "$PGDATA" || true

  # Phát hiện UID thực sự sở hữu PGDATA (GNU stat, dùng trong container Debian-based)
  PGDATA_UID=$(stat -c '%u' "$PGDATA")

  # Kiểm tra: PGDATA_UID phải là số nguyên hợp lệ và khác 0
  if [[ "$PGDATA_UID" =~ ^[0-9]+$ ]] && [ "$PGDATA_UID" != '0' ]; then
    # PGDATA do user khác sở hữu (ví dụ: host user mount volume, NFS, rootless).
    # Khởi chạy PostgreSQL trực tiếp bằng UID đó để tránh lỗi "wrong ownership".
    # Upstream entrypoint sẽ không thực hiện chown/gosu khi đã chạy non-root.
    exec gosu "$PGDATA_UID" /usr/local/bin/docker-entrypoint.sh "$@"
  fi

  # PGDATA do root sở hữu (mới tạo): chuyển ownership sang postgres
  chown -R postgres:postgres "$PGDATA"
fi

# Chuyển tiếp sang entrypoint chính của postgres image
exec /usr/local/bin/docker-entrypoint.sh "$@"
