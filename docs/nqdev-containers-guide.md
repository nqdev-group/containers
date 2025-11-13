---
layout: default
title: Hướng Dẫn Tổng Quan
nav_order: 2
---

# Hướng Dẫn Sử Dụng NQDEV Containers

![NQDEV Containers](https://img.shields.io/badge/NQDEV-Containers-blue)
![Docker](https://img.shields.io/badge/docker-ready-green)
![License](https://img.shields.io/badge/license-MIT-green)

Tài liệu hướng dẫn chi tiết về việc sử dụng các Docker container do NQDEV team phát triển. Tất cả các container đều được tối ưu cho production với hỗ trợ timezone Việt Nam và cấu hình bảo mật.

## 📋 Mục Lục

- [Tổng quan](#-tổng-quan)
- [Container Services](#-container-services)
- [Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [Cấu hình chung](#-cấu-hình-chung)
- [Examples thực tế](#-examples-thực-tế)
- [Troubleshooting](#-troubleshooting)
- [Best Practices](#-best-practices)

## 🌟 Tổng quan

NQDEV Containers là bộ sưu tập các Docker images được tùy chỉnh cho các ứng dụng phổ biến, với mục tiêu:

- **Production-ready**: Sẵn sàng triển khai trong môi trường production
- **Vietnamese localization**: Cấu hình timezone `Asia/Ho_Chi_Minh`
- **Security focused**: Tuân thủ các best practices về bảo mật
- **Performance optimized**: Tối ưu hóa hiệu suất và resource usage
- **Easy deployment**: Dễ dàng triển khai với Docker Compose

## 📦 Container Services

### 🌐 Web Services

#### NGINX (Proxy Server)

- **Image**: `nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1`
- **Features**: Custom modules, Redis integration, GeoIP, SSL/TLS
- **Port**: 32768 (HTTP), 18080 (Status)
- **Use cases**: Reverse proxy, load balancer, web server

#### HAProxy (Load Balancer)

- **Image**: `nqdev/haproxy-alpine-custom:3.1.5`
- **Features**: Lua scripting, Redis rate limiting, SSL termination
- **Port**: 18080 (HTTP), 17001 (Stats)
- **Use cases**: Load balancing, traffic management, SSL termination

### 🗄️ Database Services

#### PostgreSQL + pgAgent

- **Image**: `postgres:17.5-custom`
- **Features**: Job scheduling, HTTP extension, optimized configuration
- **Port**: 5432
- **Use cases**: Application database, scheduled jobs, HTTP requests

### 📨 Message Queue

#### RabbitMQ

- **Image**: `bitnamilegacy/rabbitmq:4.1`
- **Features**: Clustering, management UI, SSL support
- **Port**: 5672 (AMQP), 15672 (Management)
- **Use cases**: Message broker, task queues, microservices communication

### 📱 Applications

#### WordPress

- **Image**: WordPress 6.8.3 on Debian 12
- **Features**: PHP 8.4, Apache, SSL ready, WP-CLI
- **Port**: 8080 (HTTP), 8443 (HTTPS)
- **Use cases**: CMS, blog, e-commerce

## 🚀 Hướng dẫn cài đặt

### Yêu cầu hệ thống

- Docker Engine 20.10+
- Docker Compose 2.0+
- RAM: Tối thiểu 4GB, khuyến nghị 8GB+
- Disk: Tối thiểu 20GB free space

### Cài đặt nhanh

```bash
# Clone repository
git clone https://github.com/nqdev-group/containers.git
cd containers/nqdev

# Chọn service cần sử dụng
cd nginx    # hoặc haproxy, postgres-pgagent, wordpress, rabbitmq

# Khởi chạy service
docker-compose up -d --build --force-recreate --remove-orphans
```

### Cài đặt từng service

#### 1. NGINX Proxy

```bash
cd nqdev/nginx/alpine
docker-compose up -d --build --force-recreate --remove-orphans

# Kiểm tra status
curl http://localhost:18080/nginx_status
```

#### 2. HAProxy Load Balancer

```bash
cd nqdev/haproxy/alpine
docker-compose up -d --build --force-recreate --remove-orphans

# Truy cập stats dashboard
open http://localhost:17001
```

#### 3. PostgreSQL + pgAgent

```bash
cd nqdev/postgres-pgagent
docker-compose up -d --build --force-recreate --remove-orphans

# Connect to database
psql -h localhost -U superuser -d postgresdb
```

#### 4. WordPress

```bash
cd nqdev/wordpress
docker-compose up -d

# Truy cập WordPress
open http://localhost:8080
```

#### 5. RabbitMQ

```bash
cd nqdev/rabbitmq
docker-compose up -d

# Truy cập Management UI
open http://localhost:15672
```

## ⚙️ Cấu hình chung

### Environment Variables

Tất cả containers đều hỗ trợ các biến môi trường chuẩn:

```bash
TZ=Asia/Ho_Chi_Minh          # Timezone Việt Nam
CRONTAB_ENABLE=true          # Enable cron jobs (nếu hỗ trợ)
```

### Port Mapping Convention

NQDEV sử dụng quy ước port mapping để tránh conflict:

- **32768+**: HTTP services chính
- **17000-17999**: Admin/Stats interfaces
- **18000-18999**: Alternative HTTP ports
- **Standard ports**: Giữ nguyên cho database services (5432, 5672, 6379)

### Resource Limits

Mọi service đều có resource limits mặc định:

```yaml
deploy:
  resources:
    limits:
      cpus: "0.80" # 80% CPU limit
      memory: "3.2G" # 3.2GB RAM limit
    reservations:
      cpus: "0.25" # 25% CPU reserved
      memory: "256M" # 256MB RAM reserved
```

### Volume Structure

Cấu trúc thư mục volume chuẩn:

```
./data-etc/[service]/     # Configuration files
./data-log/[service]/     # Log files
./data-share/[service]/   # Shared data
./data-[type]/            # Specific data (cache, backups, etc.)
```

## 💡 Examples thực tế

### Example 1: Web Application Stack

```bash
# Triển khai full stack: NGINX + WordPress + PostgreSQL
cd nqdev/nginx/alpine && docker-compose up -d
cd ../../postgres-pgagent && docker-compose up -d
cd ../wordpress && docker-compose up -d

# Setup reverse proxy in NGINX
# Cấu hình trong data-etc/nginx/conf.d/wordpress.conf
```

### Example 2: Load Balanced API

```bash
# HAProxy + Multiple backend services
cd nqdev/haproxy/alpine
docker-compose up -d

# Cấu hình backend trong haproxy/haproxy.cfg
```

### Example 3: Microservices Communication

```bash
# RabbitMQ + Multiple services
cd nqdev/rabbitmq
docker-compose up -d

# Cấu hình message queues và routing
```

### Example 4: Development Environment

```bash
# Tất cả services cho development
docker network create nqdev-network

# Start all services với custom network
# Cấu hình trong từng docker-compose.yml
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Port conflicts

```bash
# Kiểm tra ports đang sử dụng
netstat -tlnp | grep :8080

# Thay đổi port mapping trong docker-compose.yml
ports:
  - "8081:80"  # Thay vì 8080:80
```

#### 2. Permission issues

```bash
# Fix permission cho volume mounts
sudo chown -R 1001:1001 ./data-*
chmod -R 755 ./data-*
```

#### 3. Memory issues

```bash
# Giảm memory limits trong docker-compose.yml
deploy:
  resources:
    limits:
      memory: "1G"    # Giảm từ 3.2G xuống 1G
```

#### 4. Container không start

```bash
# Xem logs chi tiết
docker-compose logs -f [service-name]

# Restart với force recreate
docker-compose down -v
docker-compose up -d --build --force-recreate --remove-orphans
```

### Debug Commands

```bash
# Container status
docker-compose ps

# Resource usage
docker stats $(docker-compose ps -q)

# Network connectivity
docker-compose exec [service] ping [other-service]

# File system check
docker-compose exec [service] df -h
```

## 📚 Best Practices

### 1. Production Deployment

```yaml
# Sử dụng external volumes cho production
volumes:
  app-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/app-data
```

### 2. Environment Management

```bash
# Sử dụng .env files cho các môi trường khác nhau
cp .env.example .env.production
cp .env.example .env.staging
```

### 3. Backup Strategy

```bash
# Script backup tự động
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec postgres pg_dump > backup_$DATE.sql
tar -czf volumes_backup_$DATE.tar.gz ./data-*
```

### 4. Monitoring Setup

```bash
# Health checks cho tất cả services
curl http://localhost:18080/nginx_status        # NGINX
curl http://localhost:17001                     # HAProxy stats
psql -h localhost -U user -c "SELECT 1"         # PostgreSQL
```

### 5. Security Hardening

```yaml
# Disable unnecessary ports exposure
# Sử dụng internal networks
# Regular security updates
# Strong passwords và SSL certificates
```

### 6. Performance Optimization

```bash
# Optimize Docker daemon
echo '{"log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}}' > /etc/docker/daemon.json

# Regular cleanup
docker system prune -a --volumes
```

## 📞 Support & Contributing

### Getting Help

- **Issues**: Tạo issue trên [GitHub Repository](https://github.com/nqdev-group/containers)
- **Documentation**: Xem README của từng service trong thư mục tương ứng
- **Community**: Join discussions trong GitHub

### Contributing

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/new-service`)
3. Commit changes (`git commit -am 'Add new service'`)
4. Push branch (`git push origin feature/new-service`)
5. Tạo Pull Request

### Development Guidelines

- Tuân thủ Docker best practices
- Sử dụng multi-stage builds khi cần thiết
- Document tất cả environment variables
- Include health checks
- Test trên multiple environments

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👥 NQDEV Team

**Maintainer**: NQDEV Platform  
**Email**: quynh@nhquydev.net  
**Website**: [nhquydev.net](https://nhquydev.net)  
**Container Registry**: [GitHub Packages](https://github.com/nqdev-group/containers/packages)

---

> 💡 **Tip**: Luôn kiểm tra logs khi có vấn đề: `docker-compose logs -f [service-name]`

> ⚠️ **Lưu ý**: Đảm bảo có đủ disk space và memory trước khi chạy multiple services cùng lúc

> 🚀 **Pro tip**: Sử dụng `docker-compose down -v` để cleanup hoàn toàn khi debugging
