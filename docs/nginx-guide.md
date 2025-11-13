---
layout: default
title: NGINX Container Guide
parent: Service Guides
nav_order: 1
---

# NGINX Container - Hướng dẫn sử dụng chi tiết

![NGINX](https://img.shields.io/badge/nginx-1.27.2-green)
![Alpine](https://img.shields.io/badge/alpine-3.20-blue)
![Custom](https://img.shields.io/badge/custom-modules-orange)

## 📋 Thông tin cơ bản

- **Image**: `nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1`
- **Base**: Alpine Linux 3.20
- **NGINX Version**: 1.27.2
- **Custom Modules**: 6+ modules tích hợp

## 🚀 Khởi động nhanh

```bash
# Di chuyển vào thư mục NGINX
cd nqdev/nginx/alpine

# Khởi chạy container
docker-compose up -d --build --force-recreate --remove-orphans

# Kiểm tra trạng thái
curl http://localhost:32768
curl http://localhost:18080/nginx_status
```

## 🧱 Tính năng nổi bật

### Custom Modules

- **headers-more-nginx-module**: Thao tác HTTP headers nâng cao
- **rate-limit-nginx-module**: Giới hạn request rate
- **ngx_http_geoip_module**: Xác định vị trí địa lý
- **ngx_http_image_filter_module**: Xử lý ảnh real-time
- **ngx_http_xslt_filter_module**: Transformation XML
- **ngx_http_js_module**: JavaScript/NJS scripting

### Features nâng cao

- **Redis Integration**: Session management và caching
- **Real IP Detection**: Từ multiple proxy layers
- **GeoIP Services**: Geographic routing
- **Multi-zone Caching**: Public và private cache
- **Automated Backup**: Configuration backups với cron
- **Status Monitoring**: Endpoint trên port 8080

## ⚙️ Cấu hình

### Environment Variables

| Variable                  | Default            | Description              |
| ------------------------- | ------------------ | ------------------------ |
| `TZ`                      | `Asia/Ho_Chi_Minh` | Container timezone       |
| `NGINX_HTTP_PORT_NUMBER`  | `80`               | HTTP port                |
| `NGINX_HTTPS_PORT_NUMBER` | `443`              | HTTPS port               |
| `CRONTAB_ENABLE`          | `false`            | Enable automated backups |

### Port Mapping

| Container Port | Host Port | Service            |
| -------------- | --------- | ------------------ |
| 80             | 32768     | HTTP main          |
| 8080           | 18080     | Status monitoring  |
| 81             | 32769     | Additional service |
| 82             | 32770     | Additional service |
| 83             | 32771     | Additional service |

### Volume Mounts

```yaml
volumes:
  - ./data-etc/nginx/nginx.conf:/etc/nginx/nginx.conf:rw
  - ./data-etc/nginx/conf.d/:/etc/nginx/conf.d:rw
  - ./data-etc/nginx/njs/:/etc/nginx/njs:rw
  - ./data-log/nginx/:/var/log/nginx:rw
  - ./data-share/GeoIP/:/usr/share/GeoIP:rw
  - ./data-share/nginx/:/usr/share/nginx:rw
```

## 📁 Cấu trúc file

### Configuration Structure

```
/etc/nginx/
├── nginx.conf                 # Main configuration
├── conf.d/                   # Server configs
│   └── nginx_status.conf     # Status endpoint
├── include/                  # Shared configs
│   ├── log.conf             # Logging setup
│   ├── proxy.conf           # Proxy settings
│   ├── ssl-ciphers.conf     # SSL configuration
│   └── ip_ranges.conf       # IP definitions
└── njs/                     # JavaScript files
```

### Cache Directories

```
/var/tmp/nginx/cache/
├── body/                    # Request body cache
├── public/                  # Public cache zone
└── private/                 # Private cache zone
```

## 🔧 Cấu hình nâng cao

### 1. Rate Limiting

```nginx
# Trong nginx.conf
http {
    # Define rate limiting zones
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general:10m rate=1r/s;

    server {
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend;
        }

        location / {
            limit_req zone=general burst=5 nodelay;
            try_files $uri $uri/ =404;
        }
    }
}
```

### 2. SSL/TLS Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    # SSL certificates
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

### 3. Reverse Proxy Setup

```nginx
upstream backend_servers {
    least_conn;
    server 192.168.1.100:8080 weight=3;
    server 192.168.1.101:8080 weight=2;
    server 192.168.1.102:8080 weight=1 backup;
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Caching
        proxy_cache private-cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
    }
}
```

### 4. GeoIP Configuration

```nginx
# Trong nginx.conf
http {
    # Load GeoIP databases
    geoip_country /usr/share/GeoIP/GeoIP.dat;
    geoip_city /usr/share/GeoIP/GeoLiteCity.dat;

    # Geographic restrictions
    map $geoip_country_code $allowed_country {
        default no;
        VN yes;
        US yes;
        JP yes;
    }

    server {
        if ($allowed_country = no) {
            return 403;
        }
    }
}
```

### 5. Image Processing

```nginx
# Dynamic image resizing
location ~ ^/resize/(\d+)x(\d+)/(.+) {
    set $width $1;
    set $height $2;
    set $image_path $3;

    image_filter resize $width $height;
    image_filter_jpeg_quality 95;
    image_filter_buffer 2M;

    try_files /$image_path =404;
}

# Thumbnails
location ~ ^/thumb/(\d+)/(.+) {
    set $size $1;
    set $image_path $2;

    image_filter resize $size $size;
    image_filter crop $size $size;

    try_files /$image_path =404;
}
```

## 📊 Monitoring

### Status Endpoint

Truy cập: http://localhost:18080/nginx_status

```
Active connections: 15
server accepts handled requests
 1234 1234 5678
Reading: 2 Writing: 5 Waiting: 8
```

### Log Monitoring

```bash
# Real-time access logs
docker-compose exec nginx-server tail -f /var/log/nginx/access.log

# Error logs
docker-compose exec nginx-server tail -f /var/log/nginx/error.log

# Custom log format
log_format detailed '$remote_addr - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent '
                   '"$http_referer" "$http_user_agent" '
                   '$request_time $upstream_response_time';
```

### Backup Monitoring

```bash
# Check automated backups
ls -la ./data-backups/nginx/

# Manual backup
docker-compose exec nginx-server /usr/local/bin/100-backup-nginx.sh
```

## 🛠️ Management Scripts

### Configuration Validation

```bash
# Test configuration
./01-verify-config.sh

# Reload without downtime
./02-reload-config.sh

# Full startup with build
./00-startup.sh
```

### Health Checks

```bash
# Syntax check
docker-compose exec nginx-server nginx -t

# Module verification
docker-compose exec nginx-server nginx -V 2>&1 | grep -o 'with-[^[:space:]]*'

# Performance test
ab -n 1000 -c 10 http://localhost:32768/
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Configuration syntax errors

```bash
# Check syntax
docker-compose exec nginx-server nginx -t

# Detailed error information
docker-compose exec nginx-server nginx -T
```

#### 2. Permission issues

```bash
# Fix file permissions
sudo chown -R 101:101 ./data-etc/nginx/
sudo chmod -R 644 ./data-etc/nginx/*.conf
```

#### 3. Module loading errors

```bash
# Check module availability
docker-compose exec nginx-server ls -la /usr/lib/nginx/modules/

# Test module load
docker-compose exec nginx-server nginx -t -c /etc/nginx/nginx.conf
```

#### 4. Performance issues

```bash
# Check worker processes
docker-compose exec nginx-server ps aux | grep nginx

# Monitor connections
watch -n 1 'curl -s http://localhost:18080/nginx_status'
```

### Debug Commands

```bash
# Container logs
docker-compose logs -f nginx-server

# Access patterns
awk '{print $1}' ./data-log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# Error analysis
grep "ERROR" ./data-log/nginx/error.log | tail -20
```

## 🚀 Production Deployment

### High Performance Setup

```nginx
# Worker optimization
worker_processes auto;
worker_connections 2048;
worker_rlimit_nofile 65535;

# Event handling
events {
    use epoll;
    multi_accept on;
}

# HTTP optimization
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    # Buffer sizes
    client_body_buffer_size 128k;
    client_max_body_size 2000m;
    large_client_header_buffers 4 16k;

    # Timeouts
    keepalive_timeout 90s;
    client_header_timeout 10s;
    client_body_timeout 10s;
    send_timeout 10s;
}
```

### Security Hardening

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;

# Hide version
server_tokens off;

# Rate limiting
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
location /login {
    limit_req zone=login burst=3 nodelay;
}
```

### SSL Best Practices

```nginx
# Strong SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;

# SSL session caching
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /path/to/ca-chain.crt;
```

## 📚 Examples

### Example 1: Static Website

```nginx
server {
    listen 80;
    server_name static.example.com;
    root /usr/share/nginx/html/static;

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

### Example 2: API Gateway

```nginx
# API rate limiting per client
map $http_authorization $api_client {
    ~^Bearer\s+(.+) $1;
    default "anonymous";
}

limit_req_zone $api_client zone=api_per_client:10m rate=100r/s;

server {
    listen 80;
    server_name api.example.com;

    location /api/v1/ {
        limit_req zone=api_per_client burst=200 nodelay;

        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        # Response modification
        more_set_headers "X-API-Version: v1";
        more_set_headers "X-Response-Time: $upstream_response_time";
    }
}
```

### Example 3: Microservices Routing

```nginx
# Service discovery via consul template (example)
upstream user_service {
    server user-service-1:8080;
    server user-service-2:8080;
}

upstream order_service {
    server order-service-1:8080;
    server order-service-2:8080;
}

server {
    listen 80;
    server_name api.microservices.com;

    location /users/ {
        rewrite ^/users/(.*)$ /$1 break;
        proxy_pass http://user_service;
    }

    location /orders/ {
        rewrite ^/orders/(.*)$ /$1 break;
        proxy_pass http://order_service;
    }
}
```

---

## 📞 Support

- **Documentation**: Xem [NGINX Official Docs](https://nginx.org/en/docs/)
- **Issues**: [GitHub Issues](https://github.com/nqdev-group/containers/issues)
- **Community**: NQDEV Discord/Slack

---

**NQDEV Team** - Platform Engineering  
📧 quynh@nhquydev.net | 🌐 [nhquydev.net](https://nhquydev.net)
