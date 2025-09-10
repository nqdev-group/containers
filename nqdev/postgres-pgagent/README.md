# PostgreSQL Docker Image with Extensions

![Docker](https://img.shields.io/badge/docker-postgresql-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 🧾 Giới thiệu

Đây là Docker image tùy chỉnh cho **PostgreSQL** được xây dựng trên base image chính thức từ Docker Hub (`postgres`). Image này bao gồm:

- PostgreSQL (mặc định: `17.5`)
- Extension `http` từ [pgsql-http](https://github.com/pramsey/pgsql-http)
- Công cụ `pgagent` để lập lịch job
- Các thư viện phát triển cần thiết (`postgresql-server-dev-*`)
- Hỗ trợ timezone `Asia/Ho_Chi_Minh`
- Khởi tạo database với các script tùy chỉnh

---

## 🧱 Thành phần bên trong

| Thành phần       | Mô tả                                                             |
| ---------------- | ----------------------------------------------------------------- |
| PostgreSQL       | Database chính, phiên bản 17.5 (hoặc tùy chỉnh qua `--build-arg`) |
| `http` Extension | Cho phép gửi HTTP từ trong PostgreSQL (cần enable trong database) |
| `pgagent`        | Hệ thống lập lịch job cho PostgreSQL                              |
| Shell scripts    | Tự động khởi tạo và cấu hình khi container khởi động              |

---

## 🏗️ Build Image

```bash
docker build -t nqdev/postgres-pgagent:latest .
```

Ghi chú: Bạn có thể thay đổi phiên bản PostgreSQL bằng `--build-arg`:

```bash
docker build --build-arg VERSION=17.5 -t nqdev/postgres-pgagent:latest .
```

## 🚀 Cách sử dụng

```bash
docker run -d \
  --name my-postgres \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -v pgdata:/nqdev/postgres/data \
  -v pglogs:/nqdev/postgres/logs \
  -p 5432:5432 \
  nqdev/postgres-pgagent:1.0
```

Các script khởi tạo sẽ tự động chạy từ thư mục `/docker-entrypoint-initdb.d/`.

## 🚀 Cách sử dụng với Docker Compose

```yaml
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# PostgreSQL + pgAgent, pgsql-http extension
# -----------------------------------------
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

services:
  postgres-pgagent:
    container_name: postgres-pgagent-custom
    image: nqdev/postgres-pgagent:latest
    # network_mode: "host"
    ports:
      - "5432:5432"
    environment:
      TZ: Asia/Ho_Chi_Minh
      POSTGRES_USER: ${POSTGRES_USER:-superuser}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-superuser}
      POSTGRES_DB: ${POSTGRES_DB:-postgresdb}
      POSTGRES_HOST_AUTH_METHOD: trust
      POSTGRES_PORT: ${POSTGRES_PORT:-5432}
      POSTGRES_INITDB_ARGS: ${POSTGRES_INITDB_ARGS:-"--data-checksums"}
    env_file:
      - .env
    volumes:
      - ./data:/var/lib/postgresql/data:rw
    extra_hosts:
      - "host.docker.internal:host-gateway" # Kết nối host localhost từ container
    dns:
      - 1.1.1.1
      - 1.0.0.1
      - 8.8.8.8
      - 8.8.4.4
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "5"
    deploy:
      resources:
        limits:
          cpus: "0.80"
          memory: "3.2G"
        reservations:
          memory: "256M"
```

## 🗂 Cấu trúc thư mục trong container

| Đường dẫn                            | Mục đích                                 |
| ------------------------------------ | ---------------------------------------- |
| `/nqdev/postgres/data`               | Dữ liệu PostgreSQL (volume mount)        |
| `/nqdev/postgres/logs`               | Log file (volume mount)                  |
| `/nqdev/postgres/scripts/*.sh`       | Các script shell tùy chỉnh               |
| `/docker-entrypoint-initdb.d/`       | Script SQL và shell để khởi tạo database |
| `/usr/lib/postgresql/17/lib/http.so` | File extension HTTP đã biên dịch         |

## 🧪 Kiểm tra extension HTTP

Sau khi container khởi động, bạn có thể kết nối vào PostgreSQL và kiểm tra:

```sql
-- Kết nối tới database
CREATE EXTENSION http;

-- Thực hiện một request
SELECT * FROM http_get('https://api.github.com');
```

## 🛠️ Biến môi trường

| Biến                | Mặc định              | Mô tả                                 |
| ------------------- | --------------------- | ------------------------------------- |
| `POSTGRES_PASSWORD` | _Không có_ (bắt buộc) | Mật khẩu cho user `postgres`          |
| `TIMEZONE`          | `Asia/Ho_Chi_Minh`    | Timezone của hệ thống bên trong image |

## 🔐 Volume gợi ý

Khi chạy container nên mount các volume sau để đảm bảo dữ liệu và logs được lưu trữ ngoài container:

```bash
-v pgdata:/nqdev/postgres/data \
-v pglogs:/nqdev/postgres/logs
```

## 📜 License

Phân phối theo giấy phép [MIT](LICENSE)

## 👨‍💻 Tác giả

### QuyIT Platform

- 📧 Email: quynh@nhquydev.net
