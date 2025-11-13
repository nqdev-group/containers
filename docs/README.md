---
layout: default
title: NQDEV Containers Documentation
---

# NQDEV Containers Documentation

Chào mừng bạn đến với tài liệu hướng dẫn sử dụng NQDEV Containers!

{: .note }

> 🎉 **Jekyll Theme**: Tài liệu này đã được setup với Jekyll theme để có trải nghiệm đọc tốt hơn trên GitHub Pages.

## 🚀 Jekyll Development Setup

### Local Development

```bash
# Di chuyển vào thư mục docs
cd docs

# Cài đặt dependencies
bundle install

# Start development server
bundle exec jekyll serve --livereload

# Truy cập: http://localhost:4000
```

### Build for Production

```bash
# Build static site
bundle exec jekyll build

# Output trong _site/ folder
```

## 📚 Tài liệu có sẵn

### 1. [Hướng Dẫn Tổng Quan](nqdev-containers-guide.md)

- Giới thiệu về tất cả containers
- Hướng dẫn cài đặt nhanh
- Cấu hình chung và port mapping
- Troubleshooting cơ bản

### 2. [NGINX Container Guide](nginx-guide.md)

- Cấu hình chi tiết NGINX với custom modules
- Rate limiting, GeoIP, SSL/TLS
- Image processing và proxy configuration
- Performance tuning và monitoring

### 3. [HAProxy Container Guide](haproxy-guide.md)

- Load balancing với Lua scripting
- Redis rate limiting integration
- SSL termination và health checks
- Advanced routing và traffic management

### 4. [Examples & Best Practices](examples-best-practices.md)

- Architecture patterns (Microservices, Three-tier)
- Production deployment examples
- Security best practices
- Monitoring, logging và performance optimization
- DevOps workflows và CI/CD

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/nqdev-group/containers.git
cd containers/nqdev

# Chọn service và khởi chạy
cd nginx/alpine  # hoặc haproxy/alpine, postgres-pgagent, etc.
docker-compose up -d --build --force-recreate --remove-orphans
```

## 📋 Services Available

| Service        | Image                                        | Ports        | Description                                  |
| -------------- | -------------------------------------------- | ------------ | -------------------------------------------- |
| **NGINX**      | `nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1` | 32768, 18080 | Web server, reverse proxy với custom modules |
| **HAProxy**    | `nqdev/haproxy-alpine-custom:3.1.5`          | 18080, 17001 | Load balancer với Lua và Redis integration   |
| **PostgreSQL** | `postgres:17.5-custom`                       | 5432         | Database với pgAgent và HTTP extension       |
| **WordPress**  | WordPress 6.8.3 on Debian 12                 | 8080, 8443   | CMS với PHP 8.4 và Apache                    |
| **RabbitMQ**   | `bitnamilegacy/rabbitmq:4.1`                 | 5672, 15672  | Message broker với clustering support        |

## 🔧 Common Commands

### Start Services

```bash
# Start individual service
cd nqdev/[service-name]/
docker-compose up -d --build --force-recreate --remove-orphans

# Start all services
docker-compose -f docker-compose.all.yml up -d
```

### Health Checks

```bash
# NGINX status
curl http://localhost:18080/nginx_status

# HAProxy stats
open http://localhost:17001

# PostgreSQL connection
psql -h localhost -U superuser -d postgresdb

# RabbitMQ management
open http://localhost:15672
```

### Logs & Debugging

```bash
# View logs
docker-compose logs -f [service-name]

# Container stats
docker stats $(docker-compose ps -q)

# Shell access
docker-compose exec [service-name] /bin/bash
```

## 🔒 Security Notes

- **Default passwords**: Đổi ngay trong production!
- **Port exposure**: Chỉ expose ports cần thiết
- **SSL certificates**: Sử dụng valid certificates
- **Resource limits**: Đã cấu hình resource limits mặc định
- **Network isolation**: Containers isolated với custom networks

## 🏗️ Architecture Patterns

### 1. Simple Web Application

```
NGINX (Reverse Proxy) → WordPress → PostgreSQL
```

### 2. Microservices

```
HAProxy (Load Balancer) → NGINX (API Gateway) → Services → PostgreSQL
                                                        ↓
                                                   RabbitMQ
```

### 3. High Availability

```
HAProxy (Primary) ──┐
                    ├─→ Multiple App Instances → Database Cluster
HAProxy (Backup) ───┘                         → Redis Cluster
```

## 📊 Monitoring & Alerting

### Built-in Monitoring

- **NGINX**: Status endpoint (`/nginx_status`)
- **HAProxy**: Stats dashboard (port 17001)
- **PostgreSQL**: Health checks và pg_stat views
- **RabbitMQ**: Management UI (port 15672)

### External Monitoring Integration

- Prometheus metrics endpoints
- ELK stack logging
- Grafana dashboards
- Custom health check scripts

## 🚀 Production Considerations

### Resource Requirements

- **Minimum**: 4GB RAM, 20GB disk
- **Recommended**: 8GB+ RAM, 50GB+ disk
- **High-load**: 16GB+ RAM, SSD storage

### Environment Variables

```bash
TZ=Asia/Ho_Chi_Minh          # Timezone
CRONTAB_ENABLE=true          # Enable cron jobs
REDIS_HOST=redis-server      # Redis integration
POSTGRES_PASSWORD=secure     # Database auth
```

### Volume Mounts

```bash
./data-etc/[service]/        # Configuration files
./data-log/[service]/        # Log files
./data-share/[service]/      # Shared data
./data-backups/              # Backup storage
```

## 🆘 Troubleshooting

### Common Issues

1. **Port conflicts**

   ```bash
   netstat -tlnp | grep :8080
   # Change port in docker-compose.yml
   ```

2. **Permission denied**

   ```bash
   sudo chown -R 1001:1001 ./data-*
   ```

3. **Out of disk space**

   ```bash
   docker system prune -a --volumes
   ```

4. **Memory issues**
   ```bash
   # Reduce resource limits in docker-compose.yml
   deploy:
     resources:
       limits:
         memory: "1G"  # Reduce from 3.2G
   ```

### Getting Help

- **Documentation**: Đọc chi tiết trong từng file guide
- **GitHub Issues**: [https://github.com/nqdev-group/containers/issues](https://github.com/nqdev-group/containers/issues)
- **Community**: Join discussions trên GitHub

## 📝 Contributing

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/new-feature`)
3. Test thay đổi
4. Submit Pull Request với mô tả chi tiết

### Development Guidelines

- Follow Docker best practices
- Document environment variables
- Include health checks
- Test on multiple environments
- Update documentation

## 📄 License

MIT License - see [LICENSE](../LICENSE) file for details.

---

## 👥 NQDEV Team

**Maintainer**: NQDEV Platform Engineering  
**Contact**: quynh@nhquydev.net  
**Website**: [nhquydev.net](https://nhquydev.net)  
**Container Registry**: [GitHub Packages](https://github.com/nqdev-group/containers/packages)

---

> 💡 **Tip**: Bắt đầu với [Hướng Dẫn Tổng Quan](nqdev-containers-guide.md) để hiểu overview, sau đó đọc guide chi tiết của service bạn cần sử dụng.

> ⚠️ **Important**: Luôn kiểm tra logs khi có vấn đề: `docker-compose logs -f [service]`

> 🚀 **Pro Tip**: Sử dụng [Examples & Best Practices](examples-best-practices.md) cho production deployment!
