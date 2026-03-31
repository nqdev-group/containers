![logo](https://raw.githubusercontent.com/filebrowser/logo/master/banner.png)

# 📂 FileBrowser Docker Compose

File Browser provides a file managing interface within a specified directory and it can be used to upload, delete, preview, rename and edit your files.
It allows the creation of multiple users and each user can have its own directory.

## 🚀 Cấu trúc thư mục

```
filebrowser/
├── compose.yml          # Docker Compose file
├── .env                # Environment variables
├── data/               # Thư mục dữ liệu chính
├── config/             # Cấu hình
│   ├── database/       # Database files
│   └── settings.json   # Cấu hình ứng dụng
└── readme.md          # File này
```

## 📖 Cách sử dụng

### 1. Khởi chạy service

```bash
# Khởi chạy
docker compose up -d

# Xem logs
docker compose logs -f filebrowser

# Dừng service
docker compose down
```

### 2. Truy cập

- **URL**: http://localhost:9099
- **Tài khoản mặc định**:
  - Username: `admin`
  - Password: `admin`

**⚠️ Quan trọng**: Đổi mật khẩu admin ngay sau khi đăng nhập lần đầu!

### 3. Cấu hình Environment (.env)

```bash
# Port mapping
FILEBROWSER_PORT=9099

# Data directory
DATA_DIR=./data

# User/Group IDs (Linux only)
# PUID=1000
# PGID=1000

# Base URL cho reverse proxy
# FB_BASEURL=/filebrowser

# Domain cho Traefik
DOMAIN=filebrowser.localhost

# Log level
LOG_LEVEL=info
```

### 4. Volume Mounts

Thêm thêm mount points nếu cần:

```yaml
volumes:
  - ./data:/srv
  - /path/to/downloads:/srv/downloads
  - /path/to/documents:/srv/documents
```

### 5. Reverse Proxy (Traefik)

Labels đã được cấu hình sẵn:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.filebrowser.rule=Host(`filebrowser.localhost`)"
  - "traefik.http.services.filebrowser.loadbalancer.server.port=80"
```

## 🔧 Tính năng

- ✅ Quản lý files/folders qua web interface
- ✅ Upload, download files
- ✅ Preview files (images, videos, documents)
- ✅ Text editor tích hợp
- ✅ Multiple users management
- ✅ Permissions system
- ✅ Search functionality
- ✅ Mobile responsive
- ✅ Healthcheck tự động
- ✅ Network isolation

## 🛡️ Bảo mật

1. **Đổi mật khẩu admin** ngay sau khi cài đặt
2. **Signup đã tắt** trong config mặc định
3. **Sử dụng HTTPS** trong production
4. **Network isolation** với bridge network
5. **Regular backup** database và config

## 🔍 Troubleshooting

### Permission Issues (Linux)

```bash
# Kiểm tra owner
ls -la data/

# Đổi owner nếu cần
sudo chown -R 1000:1000 data/
```

### Database Issues

- Database tạo tự động lần đầu
- Backup: `cp config/database/filebrowser.db backup/`

### Health Check Failed

```bash
# Kiểm tra container health
docker compose ps

# Xem logs chi tiết
docker compose logs filebrowser
```

## 📚 Tài liệu tham khảo

- **GitHub**: https://github.com/filebrowser/filebrowser
  - _builder_: https://github.com/filebrowser/builder
  - _docker-dev_: https://github.com/filebrowser/docker-dev
- **Installation**: https://filebrowser.org/installation.html
  - **Docker**: https://filebrowser.org/installation.html#docker
    - _docker image_: https://hub.docker.com/r/filebrowser/filebrowser
- **Configuration**: https://filebrowser.org/configuration.html

## 🎯 Bài viết hướng dẫn

- _Thuận Bùi_: [File Browser – Công cụ quản lý tập tin và thư mục bằng giao diện web](https://thuanbui.me/file-browser/)
- _Version customize_: https://github.com/gtsteffaniak/filebrowser

---
