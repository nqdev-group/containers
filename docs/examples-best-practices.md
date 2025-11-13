---
layout: default
title: Examples & Best Practices
nav_order: 3
---

# NQDEV Containers - Examples & Best Practices

![Examples](https://img.shields.io/badge/examples-production--ready-green)
![Best Practices](https://img.shields.io/badge/best--practices-security--focused-blue)

Tổng hợp các ví dụ thực tế và best practices khi sử dụng NQDEV containers trong production.

## 📋 Mục lục

- [🏗️ Architecture Patterns](#️-architecture-patterns)
- [🚀 Production Examples](#-production-examples)
- [🔒 Security Best Practices](#-security-best-practices)
- [📊 Monitoring & Logging](#-monitoring--logging)
- [⚡ Performance Optimization](#-performance-optimization)
- [🔧 DevOps Workflows](#-devops-workflows)

## 🏗️ Architecture Patterns

### 1. Microservices Architecture

```yaml
# Full microservices stack
version: "3.8"

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  database:
    driver: bridge

services:
  # Load Balancer
  haproxy:
    image: nqdev/haproxy-alpine-custom:3.1.5
    ports:
      - "80:80"
      - "443:443"
      - "7001:7001"
    networks:
      - frontend
      - backend
    configs:
      - source: haproxy_config
        target: /usr/local/etc/haproxy/haproxy.cfg

  # API Gateway
  nginx-gateway:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    networks:
      - frontend
      - backend
    volumes:
      - ./nginx/gateway.conf:/etc/nginx/conf.d/default.conf

  # Application Services
  user-service:
    image: user-service:latest
    networks:
      - backend
      - database
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/users

  order-service:
    image: order-service:latest
    networks:
      - backend
      - database

  # Database
  postgres:
    image: nqdev/postgres-pgagent:latest
    networks:
      - database
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Message Queue
  rabbitmq:
    image: bitnamilegacy/rabbitmq:4.1
    networks:
      - backend

volumes:
  postgres_data:

configs:
  haproxy_config:
    file: ./haproxy/microservices.cfg
```

### 2. Three-Tier Web Application

```yaml
# Classic three-tier: Presentation, Application, Database
version: "3.8"

services:
  # Presentation Tier - NGINX serving static content + reverse proxy
  web:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/three-tier.conf:/etc/nginx/nginx.conf
      - ./static:/usr/share/nginx/html
    depends_on:
      - app

  # Application Tier - WordPress or custom app
  app:
    image: nqdev/wordpress:6-debian-12
    environment:
      - WORDPRESS_DATABASE_HOST=database
      - WORDPRESS_DATABASE_NAME=webapp
    volumes:
      - app_data:/bitnami/wordpress
    depends_on:
      - database

  # Database Tier - PostgreSQL with pgAgent
  database:
    image: nqdev/postgres-pgagent:latest
    environment:
      - POSTGRES_DB=webapp
      - POSTGRES_USER=webuser
      - POSTGRES_PASSWORD=securepassword
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  app_data:
  db_data:
```

## 🚀 Production Examples

### 1. High-Traffic E-commerce Site

```yaml
# E-commerce platform with auto-scaling
version: "3.8"

x-logging: &default-logging
  driver: "json-file"
  options:
    max-size: "100m"
    max-file: "3"

services:
  # Load Balancer with SSL termination
  loadbalancer:
    image: nqdev/haproxy-alpine-custom:3.1.5
    ports:
      - "80:80"
      - "443:443"
    environment:
      - REDIS_HOST=redis-cache
    volumes:
      - ./ssl:/usr/local/etc/haproxy/ssl:ro
      - ./haproxy/ecommerce.cfg:/usr/local/etc/haproxy/haproxy.cfg
    logging: *default-logging
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 1G
          cpus: "1"

  # NGINX for static assets và CDN
  cdn:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    volumes:
      - ./nginx/cdn.conf:/etc/nginx/nginx.conf
      - media_storage:/usr/share/nginx/html/media
    logging: *default-logging
    deploy:
      replicas: 3

  # WordPress application servers
  wordpress:
    image: nqdev/wordpress:6-debian-12
    environment:
      - WORDPRESS_DATABASE_HOST=database
      - WORDPRESS_ENABLE_HTTPS=yes
      - WORDPRESS_DATABASE_NAME=ecommerce
    volumes:
      - wordpress_data:/bitnami/wordpress
    logging: *default-logging
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 2G
          cpus: "2"

  # Database cluster
  database:
    image: nqdev/postgres-pgagent:latest
    environment:
      - POSTGRES_DB=ecommerce
      - POSTGRES_USER=ecommerce_user
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    secrets:
      - db_password
    logging: *default-logging

  # Redis for caching và sessions
  redis-cache:
    image: redis:alpine3.18
    command: redis-server --appendonly yes --requirepass redis_password
    volumes:
      - redis_data:/data
    logging: *default-logging

  # Message queue cho background jobs
  rabbitmq:
    image: bitnamilegacy/rabbitmq:4.1
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS_FILE=/run/secrets/rabbitmq_password
    volumes:
      - rabbitmq_data:/bitnami/rabbitmq/mnesia
    secrets:
      - rabbitmq_password
    logging: *default-logging

volumes:
  wordpress_data:
  db_data:
  redis_data:
  rabbitmq_data:
  media_storage:

secrets:
  db_password:
    file: ./secrets/db_password.txt
  rabbitmq_password:
    file: ./secrets/rabbitmq_password.txt
```

### 2. API-First Application

```yaml
# Microservices API platform
version: "3.8"

services:
  # API Gateway với rate limiting
  api-gateway:
    image: nqdev/haproxy-alpine-custom:3.1.5
    ports:
      - "80:80"
      - "443:443"
    environment:
      - REDIS_HOST=redis-rate-limit
      - REDIS_PORT=6379
    volumes:
      - ./haproxy/api-gateway.cfg:/usr/local/etc/haproxy/haproxy.cfg
      - ./haproxy/lua:/nqdev/haproxy/lua
    depends_on:
      - redis-rate-limit

  # Authentication service
  auth-service:
    image: auth-api:latest
    environment:
      - JWT_SECRET_FILE=/run/secrets/jwt_secret
      - DATABASE_URL=postgresql://auth_user:auth_pass@postgres:5432/auth
    secrets:
      - jwt_secret

  # User management service
  user-service:
    image: user-api:latest
    environment:
      - DATABASE_URL=postgresql://user_user:user_pass@postgres:5432/users

  # Order processing service
  order-service:
    image: order-api:latest
    environment:
      - DATABASE_URL=postgresql://order_user:order_pass@postgres:5432/orders
      - RABBITMQ_URL=amqp://admin:admin@rabbitmq:5672

  # Notification service
  notification-service:
    image: notification-api:latest
    environment:
      - RABBITMQ_URL=amqp://admin:admin@rabbitmq:5672
      - EMAIL_SERVICE_KEY_FILE=/run/secrets/email_key
    secrets:
      - email_key

  # Database
  postgres:
    image: nqdev/postgres-pgagent:latest
    environment:
      - POSTGRES_MULTIPLE_DATABASES=auth,users,orders
    volumes:
      - ./postgres/init:/docker-entrypoint-initdb.d
      - postgres_data:/var/lib/postgresql/data

  # Message queue
  rabbitmq:
    image: bitnamilegacy/rabbitmq:4.1
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin

  # Rate limiting cache
  redis-rate-limit:
    image: redis:alpine3.18

volumes:
  postgres_data:

secrets:
  jwt_secret:
    file: ./secrets/jwt_secret.txt
  email_key:
    file: ./secrets/email_key.txt
```

## 🔒 Security Best Practices

### 1. SSL/TLS Configuration

#### HAProxy SSL Termination

```haproxy
# /haproxy/ssl-config.cfg
global
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

frontend https_frontend
    bind *:443 ssl crt /usr/local/etc/haproxy/ssl/ alpn h2,http/1.1

    # Security headers
    http-response set-header Strict-Transport-Security "max-age=31536000; includeSubDomains"
    http-response set-header X-Frame-Options DENY
    http-response set-header X-Content-Type-Options nosniff
    http-response set-header X-XSS-Protection "1; mode=block"

    # Hide server information
    http-response del-header Server
    http-response del-header X-Powered-By
```

#### NGINX SSL Configuration

```nginx
# /nginx/ssl-security.conf
server {
    listen 443 ssl http2;

    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # SSL optimization
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'" always;
}
```

### 2. Access Control & Authentication

#### IP-based Access Control

```yaml
# docker-compose.security.yml
version: "3.8"

services:
  secure-app:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    volumes:
      - ./nginx/security.conf:/etc/nginx/nginx.conf
    environment:
      - TRUSTED_IPS=192.168.1.0/24,10.0.0.0/8
```

```nginx
# /nginx/security.conf
geo $trusted_ip {
    default 0;
    192.168.1.0/24 1;
    10.0.0.0/8 1;
    172.16.0.0/12 1;
}

server {
    if ($trusted_ip = 0) {
        return 403;
    }

    # Rate limiting
    limit_req zone=general burst=10 nodelay;

    location /admin {
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

### 3. Database Security

```yaml
# Secure PostgreSQL setup
version: "3.8"

services:
  database:
    image: nqdev/postgres-pgagent:latest
    environment:
      - POSTGRES_DB_FILE=/run/secrets/db_name
      - POSTGRES_USER_FILE=/run/secrets/db_user
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
      - POSTGRES_HOST_AUTH_METHOD=scram-sha-256
      - POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256 --data-checksums
    secrets:
      - db_name
      - db_user
      - db_password
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./postgres/postgresql.conf:/var/lib/postgresql/data/postgresql.conf
    networks:
      - database_network

secrets:
  db_name:
    file: ./secrets/db_name.txt
  db_user:
    file: ./secrets/db_user.txt
  db_password:
    file: ./secrets/db_password.txt

networks:
  database_network:
    driver: bridge
    internal: true # No external access
```

## 📊 Monitoring & Logging

### 1. Centralized Logging

```yaml
# ELK Stack integration
version: "3.8"

x-logging: &elk-logging
  driver: "gelf"
  options:
    gelf-address: "udp://logstash:12201"
    tag: "{{.ImageName}}/{{.Name}}/{{.ID}}"

services:
  nginx:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    logging: *elk-logging
    volumes:
      - ./nginx/logging.conf:/etc/nginx/nginx.conf

  haproxy:
    image: nqdev/haproxy-alpine-custom:3.1.5
    logging: *elk-logging

  # Log aggregation
  logstash:
    image: logstash:8.11.0
    ports:
      - "12201:12201/udp"
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    environment:
      - "LS_JAVA_OPTS=-Xmx256m -Xms256m"

  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  kibana:
    image: kibana:8.11.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200

volumes:
  elasticsearch_data:
```

### 2. Metrics Collection

```yaml
# Prometheus monitoring
version: "3.8"

services:
  # Application với metrics endpoint
  nginx:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    volumes:
      - ./nginx/metrics.conf:/etc/nginx/nginx.conf
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=8080"
      - "prometheus.io/path=/nginx_status"

  # Metrics collector
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--web.console.libraries=/etc/prometheus/console_libraries"
      - "--web.console.templates=/etc/prometheus/consoles"

  # Dashboard
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards

volumes:
  grafana_data:
```

## ⚡ Performance Optimization

### 1. Caching Strategy

```yaml
# Multi-layer caching
version: "3.8"

services:
  # CDN layer
  nginx-cdn:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    volumes:
      - ./nginx/cdn.conf:/etc/nginx/nginx.conf
      - static_content:/usr/share/nginx/html
    deploy:
      replicas: 3

  # Application cache
  redis-app-cache:
    image: redis:alpine3.18
    command: redis-server --maxmemory 1gb --maxmemory-policy allkeys-lru

  # Session store
  redis-sessions:
    image: redis:alpine3.18
    command: redis-server --maxmemory 512mb --maxmemory-policy noeviction

  # Database query cache
  postgres:
    image: nqdev/postgres-pgagent:latest
    volumes:
      - ./postgres/optimized.conf:/var/lib/postgresql/data/postgresql.conf

volumes:
  static_content:
```

```nginx
# /nginx/cdn.conf - Aggressive caching
server {
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        gzip_static on;
    }

    location /api/ {
        # API response caching
        proxy_cache api_cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating;
        add_header X-Cache-Status $upstream_cache_status;
    }
}
```

### 2. Database Optimization

```sql
-- /postgres/init/optimization.sql
-- Connection pooling
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';

-- Query optimization
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET seq_page_cost = 1;
ALTER SYSTEM SET default_statistics_target = 100;

-- Logging optimization
ALTER SYSTEM SET log_statement = 'mod';
ALTER SYSTEM SET log_min_duration_statement = 1000;

SELECT pg_reload_conf();
```

## 🔧 DevOps Workflows

### 1. CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build and push images
        env:
          REGISTRY: ghcr.io
        run: |
          echo ${{ secrets.GITHUB_TOKEN }} | docker login $REGISTRY -u ${{ github.actor }} --password-stdin

          # Build custom images
          docker build -t $REGISTRY/nqdev/app:${{ github.sha }} ./app
          docker push $REGISTRY/nqdev/app:${{ github.sha }}

      - name: Deploy to production
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.PRODUCTION_HOST }}
          username: deploy
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /opt/app
            export IMAGE_TAG=${{ github.sha }}
            docker-compose -f docker-compose.prod.yml pull
            docker-compose -f docker-compose.prod.yml up -d --remove-orphans
            docker system prune -f
```

### 2. Health Checks & Auto-healing

```yaml
# docker-compose.health.yml
version: "3.8"

services:
  nginx:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

  postgres:
    image: nqdev/postgres-pgagent:latest
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### 3. Backup & Disaster Recovery

```bash
#!/bin/bash
# scripts/backup.sh

set -euo pipefail

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Database backup
docker-compose exec -T postgres pg_dumpall -U postgres > "$BACKUP_DIR/db_backup_$DATE.sql"

# Application data backup
docker run --rm \
  -v app_data:/data \
  -v "$BACKUP_DIR:/backup" \
  alpine tar czf "/backup/app_data_$DATE.tar.gz" -C /data .

# Configuration backup
tar czf "$BACKUP_DIR/configs_$DATE.tar.gz" \
  ./nginx \
  ./haproxy \
  ./docker-compose*.yml

# Upload to S3 (optional)
aws s3 sync "$BACKUP_DIR" "s3://mybucket/backups/$(date +%Y/%m/%d)/"

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete

echo "Backup completed: $DATE"
```

### 4. Auto-scaling Configuration

```yaml
# docker-compose.scale.yml
version: "3.8"

services:
  nginx:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  app:
    image: myapp:latest
    deploy:
      replicas: 5
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
      placement:
        max_replicas_per_node: 2
      resources:
        limits:
          memory: 1G
          cpus: "1"
        reservations:
          memory: 512M
          cpus: "0.5"
```

## 🎯 Environment-specific Configurations

### Development Environment

```yaml
# docker-compose.dev.yml
version: "3.8"

services:
  nginx:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    volumes:
      - ./nginx/dev.conf:/etc/nginx/nginx.conf
      - ./app:/usr/share/nginx/html
    environment:
      - NGINX_LOG_LEVEL=debug

  postgres:
    image: nqdev/postgres-pgagent:latest
    environment:
      - POSTGRES_HOST_AUTH_METHOD=trust # Dev only!
    ports:
      - "5432:5432" # Expose for dev tools
```

### Staging Environment

```yaml
# docker-compose.staging.yml
version: "3.8"

services:
  nginx:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    environment:
      - ENVIRONMENT=staging
    labels:
      - "staging=true"

  postgres:
    image: nqdev/postgres-pgagent:latest
    environment:
      - POSTGRES_HOST_AUTH_METHOD=scram-sha-256
    # No port exposure for security
```

### Production Environment

```yaml
# docker-compose.prod.yml
version: "3.8"

x-logging: &default-logging
  driver: "json-file"
  options:
    max-size: "100m"
    max-file: "3"

services:
  nginx:
    image: nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1
    logging: *default-logging
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: "1"
    secrets:
      - ssl_cert
      - ssl_key

secrets:
  ssl_cert:
    external: true
  ssl_key:
    external: true
```

---

## 📚 Additional Resources

### Documentation Links

- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Docker Compose Production Guide](https://docs.docker.com/compose/production/)
- [Security Scanning](https://docs.docker.com/engine/scan/)

### Monitoring Tools

- [Prometheus](https://prometheus.io/docs/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [ELK Stack](https://www.elastic.co/elastic-stack/)

### Security Resources

- [OWASP Container Security](https://owasp.org/www-project-container-security/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Snyk Container Security](https://snyk.io/learn/container-security/)

---

**NQDEV Team** - Platform Engineering  
📧 quynh@nhquydev.net | 🌐 [nhquydev.net](https://nhquydev.net)
