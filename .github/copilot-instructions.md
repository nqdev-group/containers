# NQDEV Containers Library - AI Coding Instructions

This repository contains custom Docker containers for popular applications, maintained by the NQDEV team. Each container is production-ready with Vietnamese timezone support and extensive customization.

## Project Architecture

### Repository Structure

- `nqdev/[service]/` - Root directory for each service
- `nqdev/[service]/[version]/[os]/` - Versioned builds (e.g., `6/debian-12/` for WordPress)
- `nqdev/[service]/alpine/` - Alpine Linux variants (preferred for production)
- Each service includes `docker-compose.yml`, `Dockerfile`, and comprehensive README

### Container Categories

1. **Web Services**: nginx (with Lua scripting), haproxy (with Redis integration)
2. **Databases**: postgres-pgagent (with HTTP extension and job scheduling)
3. **Applications**: wordpress (Bitnami-based), rabbitmq (custom configurations)

## Development Patterns

### Docker Compose Standards

```yaml
# Standard header with service info and command references
# # # # # SERVICE_NAME - Description
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
# # # # #

services:
  service-name:
    container_name: service-name-custom # Always suffix with '-custom'
    image: nqdev/service:version-tag
    build:
      context: ./
      dockerfile: ./Dockerfile
    ports:
      - "external:internal" # Use non-standard external ports (32768+, 17001+, 18080+)
    environment:
      - TZ=Asia/Ho_Chi_Minh # Always set Vietnamese timezone
    volumes:
      - ./config:/container/config:rw # Mount configuration directories
    deploy:
      resources:
        limits:
          cpus: "0.80" # 80% CPU limit
          memory: "3.2G" # Memory limits based on service requirements
```

### Dockerfile Conventions

- **ARG declarations**: Define version variables at top (`ARG NGINX_VERSION=1.27.2`)
- **Maintainer label**: `LABEL maintainer="QuyIT Platform <quynh@nhquydev.net>"`
- **Environment setup**: Standard ENV vars for timezone and service configuration
- **Multi-stage builds**: Use builder stages for compilation, minimal runtime images
- **Package cleanup**: Always `rm -rf /var/cache/apk/*` after package installations

### Service-Specific Patterns

#### NGINX

- **Custom modules**: Headers manipulation, GeoIP, rate limiting, Lua scripting
- **Configuration structure**: `/etc/nginx/conf.d/`, `/etc/nginx/include/`, `/etc/nginx/njs/`
- **Startup scripts**: `00-startup.sh`, `01-verify-config.sh`, `02-reload-config.sh`
- **Cron integration**: Automated backup and monitoring via `CRONTAB_ENABLE=true`

#### HAProxy

- **Lua integration**: Redis connectors for rate limiting and session management
- **Configuration**: Extensive `haproxy.cfg` with logging to stdout, Redis backends
- **Load balancing**: Multi-backend support with health checks and ACL filtering

#### PostgreSQL

- **Extensions**: pgagent for job scheduling, pgsql-http for HTTP requests
- **Initialization**: Custom SQL scripts in `docker-entrypoint-initdb.d/`
- **Error handling**: Comprehensive error trapping in shell scripts with `set -Eeo pipefail`

### Build and Deployment

#### GitHub Actions Integration

- Workflow files: `ghcr-publish-[service].yml` for automated builds
- Versioning: `1.0.${{ github.run_number }}` pattern for builds
- Registry: GitHub Container Registry (GHCR) with Docker Hub fallback

#### Local Development

```bash
# Standard startup command (documented in compose headers)
docker-compose up -d --build --force-recreate --remove-orphans

# Build specific version with custom args
docker build -t nqdev/service:tag --build-arg VERSION=x.y.z .
```

## File Naming and Configuration Patterns

### Volume Mounts

- Configuration: `./config` or `./[service]/` to `/usr/local/etc/[service]`
- Data persistence: `./data-[type]/` pattern (e.g., `./data-log/`, `./data-share/`)
- Logs: Always mount to `./data-log/[service]/` for external access

### Environment Variables

- Use `.env` files for sensitive configuration
- Standard variables: `TZ`, `[SERVICE]_USER`, `[SERVICE]_PASSWORD`, `[SERVICE]_PORT`
- Redis integration: `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD` for services using Redis

### Security and Resource Management

- Non-root execution where possible (`user: root` only when necessary)
- Resource limits in compose files (CPU and memory constraints)
- DNS configuration: Standard public DNS servers (8.8.8.8, 1.1.1.1)

## Common Commands

```bash
# Service management
docker-compose up -d --build --force-recreate --remove-orphans
docker-compose down -v

# Configuration testing (service-specific)
nginx -t                    # Test NGINX config
haproxy -f config -c        # Test HAProxy config

# Log monitoring
docker-compose logs -f [service]
```

When modifying containers, preserve the Vietnamese localization (`Asia/Ho_Chi_Minh` timezone), maintain the established port mapping patterns, and ensure all services include proper resource constraints and health monitoring.
