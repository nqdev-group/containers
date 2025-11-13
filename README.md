<p align="center">
    <img width=auto height=auto src="https://cdn-s3-000.quyit.id.vn/logo-nqdev.png" />
</p>

<p align="center">
    <a href="https://twitter.com/nqdev"><img src="https://badgen.net/badge/twitter/@nqdev/1DA1F2?icon&label" /></a>
    <a href="https://github.com/nqdev-group/containers"><img src="https://badgen.net/github/stars/nqdev-group/containers?icon=github" /></a>
    <a href="https://github.com/nqdev-group/containers"><img src="https://badgen.net/github/forks/nqdev-group/containers?icon=github" /></a>
    <a href="https://github.com/nqdev-group/containers"><img src="https://badgen.net/github/license/nqdev-group/containers" /></a>
</p>

# NQDEV Containers Library 🐳

**Production-ready Docker containers** for popular applications, developed and maintained by the [NQDEV Team](https://nhquydev.net). Each container is optimized for performance, security, and Vietnamese timezone support.

---

## 🚀 Available Services

### 🌐 Web Services & Reverse Proxies

| Service                         | Version | Features                                           | Size  | Status        |
| ------------------------------- | ------- | -------------------------------------------------- | ----- | ------------- |
| **[NGINX](./nqdev/nginx/)**     | 1.27.2  | Custom modules, Lua scripting, Redis integration   | ~45MB | ✅ Production |
| **[HAProxy](./nqdev/haproxy/)** | 3.1.5   | Load balancing, Lua scripting, Redis rate limiting | ~35MB | ✅ Production |

### 🗄️ Databases & Message Queues

| Service                                               | Version | Features                                        | Size   | Status        |
| ----------------------------------------------------- | ------- | ----------------------------------------------- | ------ | ------------- |
| **[PostgreSQL + pgAgent](./nqdev/postgres-pgagent/)** | 16      | Job scheduling, HTTP extension, automated tasks | ~280MB | ✅ Production |
| **[RabbitMQ](./nqdev/rabbitmq/)**                     | 4.1     | Message broker, management UI, cluster support  | ~180MB | ✅ Production |

### 🖥️ Applications & CMS

| Service                             | Version | Features                                               | Size   | Status        |
| ----------------------------------- | ------- | ------------------------------------------------------ | ------ | ------------- |
| **[WordPress](./nqdev/wordpress/)** | 6.x     | Bitnami-based, optimized PHP, MySQL/PostgreSQL support | ~420MB | ✅ Production |

---

## 🎯 Why Choose NQDEV Containers?

### ✨ **Production-Ready Features**

- ⚡ **Performance Optimized**: Minimal Alpine Linux base with efficient resource usage
- 🛡️ **Security Focused**: Regular security updates, non-root execution where possible
- 🇻🇳 **Vietnamese Localization**: `Asia/Ho_Chi_Minh` timezone and proper UTF-8 support
- 📊 **Comprehensive Monitoring**: Built-in health checks and status endpoints
- 🔄 **Automated Backups**: Cron-based configuration and data backups

### 🏗️ **Advanced Customizations**

- **NGINX**: Custom modules (headers-more, rate-limiting, GeoIP, image processing)
- **HAProxy**: Lua scripting with Redis integration for advanced load balancing
- **PostgreSQL**: pgAgent job scheduler and pgsql-http extension for HTTP requests
- **WordPress**: Optimized PHP configuration with enhanced security headers

### 🐳 **Container Excellence**

- **Multi-stage builds** for optimal image sizes
- **Structured logging** with JSON output format
- **Environment variable** configuration for all services
- **Docker Compose** ready with comprehensive examples
- **Resource limits** and health monitoring included

---

## 🚀 Quick Start

### Method 1: Docker Compose (Recommended)

```bash
# Clone repository
git clone https://github.com/nqdev-group/containers.git
cd containers/nqdev/[SERVICE]

# Start service
docker-compose up -d --build --force-recreate --remove-orphans

# Stop service
docker-compose down -v
```

### Method 2: Direct Docker Pull

```bash
# Pull from GitHub Container Registry
docker pull ghcr.io/nqdev-group/[SERVICE]:[TAG]

# Or from Docker Hub
docker pull nqdev/[SERVICE]:[TAG]
```

### Method 3: Download Compose File

```bash
# Download and run specific service
curl -sSL https://raw.githubusercontent.com/nqdev-group/containers/main/nqdev/[SERVICE]/docker-compose.yml > docker-compose.yml
docker-compose up -d
```

---

## 📦 Container Architecture

### Standard Directory Structure

```
nqdev/[service]/
├── docker-compose.yml          # Production-ready compose file
├── Dockerfile                  # Multi-stage optimized build
├── README.md                   # Detailed service documentation
├── [version]/                  # Version-specific builds
│   └── [os]/                   # OS-specific variants
├── config/                     # Configuration templates
├── scripts/                    # Management and startup scripts
└── examples/                   # Usage examples and templates
```

### Resource Management

All containers include:

- **CPU limits**: Typically 80% (0.80 cores) with 25% reservation
- **Memory limits**: Service-appropriate (256MB-3.2GB)
- **Health checks**: Automated monitoring with restart policies
- **Log rotation**: Structured logging with size limits

---

## ⚙️ Configuration Standards

### Environment Variables

| Variable             | Default            | Description            |
| -------------------- | ------------------ | ---------------------- |
| `TZ`                 | `Asia/Ho_Chi_Minh` | Container timezone     |
| `[SERVICE]_PORT`     | Service default    | Main service port      |
| `[SERVICE]_USER`     | `admin`            | Service admin username |
| `[SERVICE]_PASSWORD` | Auto-generated     | Service admin password |

### Port Conventions

- **Web services**: 32768+ for external, standard internal ports
- **Database services**: 17000+ for external access
- **Monitoring/Stats**: 18080+ for status endpoints
- **Management UIs**: 15000+ for admin interfaces

### Volume Patterns

```yaml
volumes:
  - ./config:/service/config:rw # Configuration files
  - ./data-[type]:/service/data:rw # Persistent data
  - ./data-log:/var/log/service:rw # Log files
  - ./data-share:/usr/share/service:rw # Shared assets
```

---

## 🛠️ Service-Specific Examples

### NGINX with Custom Modules

```bash
# Advanced web server with Lua scripting
cd nqdev/nginx/
docker-compose up -d

# Access points:
# - Main site: http://localhost:32768
# - Status: http://localhost:18080/nginx_status
# - Features: Rate limiting, GeoIP, image processing
```

### HAProxy Load Balancer

```bash
# Load balancer with Redis rate limiting
cd nqdev/haproxy/
docker-compose up -d

# Access points:
# - Load balancer: http://localhost:18080
# - Stats dashboard: http://localhost:17001
# - Features: Lua scripting, SSL termination
```

### PostgreSQL with Job Scheduler

```bash
# Database with automated job scheduling
cd nqdev/postgres-pgagent/
docker-compose up -d

# Access:
# - Database: localhost:5432
# - Features: pgAgent jobs, HTTP extensions
```

---

## 🔧 Development Workflow

### Local Development

```bash
# Test configuration changes
docker-compose config

# Rebuild with latest changes
docker-compose up -d --build --force-recreate

# View service logs
docker-compose logs -f [service-name]

# Execute commands inside container
docker-compose exec [service-name] [command]
```

### Production Deployment

```bash
# Production environment setup
cp docker-compose.yml docker-compose.prod.yml

# Modify resource limits and security settings
# Deploy with production configuration
docker-compose -f docker-compose.prod.yml up -d
```

### Health Monitoring

```bash
# Check container health
docker-compose ps

# Monitor resource usage
docker stats

# View detailed container info
docker inspect [container-name]
```

---

## 📊 Monitoring & Management

### Built-in Monitoring

- **NGINX**: Status endpoint on port 8080 with connection metrics
- **HAProxy**: Stats dashboard on port 7001 with real-time load balancer stats
- **PostgreSQL**: pg_stat monitoring and automated job execution logs
- **RabbitMQ**: Management UI with queue and cluster monitoring

### Automated Backups

```bash
# Enable automated backups (where supported)
export CRONTAB_ENABLE=true
export BACKUP_RETENTION_DAYS=7

# Manual backup execution
docker-compose exec [service] /scripts/backup.sh
```

### Log Management

All services provide:

- **Structured logging** in JSON format
- **Log rotation** with configurable retention
- **External log mounting** for persistent storage
- **Error tracking** with detailed stack traces

---

## 🔒 Security Features

### Container Security

- **Non-root execution** where possible
- **Read-only filesystems** for configuration directories
- **Network isolation** with custom networks
- **Resource constraints** to prevent resource exhaustion
- **Regular security updates** via automated CI/CD

### Service-Level Security

- **SSL/TLS encryption** with modern cipher suites
- **Rate limiting** with Redis-backed counters
- **IP whitelisting/blacklisting** support
- **Security headers** (HSTS, CSP, X-Frame-Options)
- **Input validation** and sanitization

---

## 🌟 Advanced Features

### Redis Integration

Services with Redis support:

- **NGINX**: Session caching and rate limiting
- **HAProxy**: Centralized rate limiting and health checks
- **WordPress**: Object caching and session storage

### Lua Scripting

**NGINX & HAProxy** include Lua engines for:

- Dynamic request routing
- Custom authentication logic
- Advanced rate limiting algorithms
- Geographic traffic routing
- Custom response generation

### Job Scheduling

**PostgreSQL + pgAgent** provides:

- Automated database maintenance
- Custom SQL script execution
- Data backup scheduling
- Report generation
- ETL pipeline automation

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 Report Issues

- [Bug Reports](https://github.com/nqdev-group/containers/issues/new?template=bug_report.md)
- [Feature Requests](https://github.com/nqdev-group/containers/issues/new?template=feature_request.md)

### 💻 Code Contributions

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Test** your changes thoroughly
4. **Submit** a pull request with detailed description

### 📖 Documentation

- Improve existing documentation
- Add usage examples
- Translate to other languages
- Share production deployment experiences

### Development Standards

- Follow existing **Docker best practices**
- Maintain **Alpine Linux** base images where possible
- Include **comprehensive documentation**
- Add **health checks** and **resource limits**
- Test on **multiple architectures** (amd64, arm64)

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

---

## 👨‍💻 Support & Maintainer

**NQDEV Team** - _Production Infrastructure Specialists_

- 📧 **Email**: [quynh@nhquydev.net](mailto:quynh@nhquydev.net)
- 🌐 **Website**: [nhquydev.net](https://nhquydev.net)
- 🐙 **GitHub**: [@nqdev-group](https://github.com/nqdev-group)
- 🐳 **Docker Hub**: [hub.docker.com/u/nqdev](https://hub.docker.com/u/nqdev)
- 📦 **Container Registry**: [GitHub Packages](https://github.com/nqdev-group/containers/pkgs)

### Get Help

- 💬 **Issues**: [GitHub Issues](https://github.com/nqdev-group/containers/issues)
- 📚 **Documentation**: [Service-specific README files](./nqdev/)
- 🔄 **Updates**: [GitHub Releases](https://github.com/nqdev-group/containers/releases)

---

<p align="center">
    <strong>Built with ❤️ by the NQDEV Team for the Vietnamese developer community</strong>
</p>
