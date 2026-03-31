# NQDEV Containers Library - AI Coding Instructions

This repository contains custom Docker containers for popular applications, maintained by the NQDEV team. Each container is production-ready with Vietnamese timezone support and extensive customization.

## Project Architecture

### Repository Structure

- `nqdev/[service]/` - Root directory for each service
- `nqdev/[service]/[version]/[os]/` - Versioned builds (e.g., `6/debian-12/` for WordPress)
- `nqdev/[service]/alpine/` - Alpine Linux variants (preferred for production)
- `minideb/` - Custom base images (debian-base, bitnami, java-base, node-base, dotnet-base)
- Each service includes `docker-compose.yml`, `Dockerfile`, and comprehensive README

### Service Catalog

| Service | Path | Base |
|---------|------|------|
| **nginx** | `nqdev/nginx/alpine/` | nginx:1.27.2-alpine + LuaJIT, headers-more, GeoIP, rate-limit modules |
| **haproxy** | `nqdev/haproxy/alpine/` | haproxytech/haproxy-alpine:3.1.5 + Lua 5.4, LuaRocks, Redis-Lua |
| **postgres-pgagent** | `nqdev/postgres-pgagent/` | postgres:17 (multi-stage, compiles pgsql-http from source) |
| **rabbitmq** | `nqdev/rabbitmq/4.1/debian-12/` | bitnami/minideb:bookworm (pre-built Erlang + RabbitMQ) |
| **wordpress** | `nqdev/wordpress/6/debian-12/` | bitnami/minideb:bookworm (PHP 8.4, Apache 2.4) |
| **jenkins** | `nqdev/jenkins/debian/` | debian:trixie-slim + jlink-optimized JRE (multi-stage) |
| **ansible** | `nqdev/ansible/` | Ubuntu + SSH, Ansible, Fail2Ban, passwordless-sudo admin user |
| **github-runner** | `nqdev/github-runner/` | Self-hosted GitHub Actions runner |
| **syslog-ng** | `nqdev/syslog-ng/` | Centralized log aggregation with logrotate + cron |
| **gitbook** | `nqdev/gitbook/` | Node 6-based GitBook documentation server |
| **chromium-docker** | `nqdev/chromium-docker/` | Headless Chromium on Ubuntu 20.04 |
| **filebrowser** | `nqdev/filebrowser/` | ghcr.io/gtsteffaniak/filebrowser web file manager |

### Base Images (`minideb/`)

- `debian-base/` - Hardened Debian 12 slim; non-root `nqdev` user (uid/gid **10001**), tini init
- `bitnami/` - bitnami/minideb:trixie with `install_packages` helper (use instead of `apt-get`)
- `java-base/`, `node-base/`, `dotnet-base/` - runtime-specific extensions of debian-base

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

- **ARG declarations**: Define version variables before `FROM` so they can parameterize the base image (`ARG NGINX_VERSION=1.27.2`)
- **OCI labels**: All images use the full OCI label set — `org.opencontainers.image.title`, `.version`, `.description`, `.source`, `.vendor`, `.licenses`, `.created`, `.authors`, `.base.name`; plus `maintainer="QuyIT Platform <quynh@nhquydev.net>"`
- **Environment setup**: Always set `TZ=Asia/Ho_Chi_Minh` and `LANG=C.UTF-8`/`LC_ALL=C.UTF-8`
- **Multi-stage builds**: Use builder stages for compilation (postgres pgsql-http, Jenkins jlink JRE), copy only artifacts to runtime image
- **Package cleanup (Alpine)**: `apk add --no-cache … && rm -rf /var/cache/apk/*` in one layer
- **Package cleanup (Debian)**: `apt-get install -y --no-install-recommends … && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`
- **Bitnami services**: Use `install_packages` helper (already on PATH) instead of `apt-get`
- **Script installation**: `COPY scripts/ /nqdev/scripts/` then `chmod +x /nqdev/scripts/*.sh && dos2unix /nqdev/scripts/*.sh` — always run `dos2unix` to handle Windows line endings
- **Shell scripts**: Begin with `set -Eeo pipefail` for proper error trapping

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

- **Extensions**: pgagent for job scheduling, pgsql-http (compiled from source in builder stage) for HTTP requests
- **Initialization**: SQL scripts numbered `10-init-http.sql`, `11-init-pgagent.sql` in `docker-entrypoint-initdb.d/`; shell scripts use `set -Eeo pipefail`
- **Ownership handling**: `docker-entrypoint-init.sh` detects PGDATA owner UID via `stat -c '%u'` and `exec gosu <uid>` when non-root (handles NFS/rootless/Docker Desktop), otherwise chowns to postgres

### Build and Deployment

#### GitHub Actions Integration

- Workflow files: `ghcr-publish-[service].yml` for automated builds
- **Versioning**: A reusable composite action (`.github/actions/set-version/`) reads the `VERSION` file (default `"1.0"`) and exports `VERSION=${BASE_VERSION}.${{ github.run_number }}` to `GITHUB_ENV`
- Service-specific tag formats: NGINX uses `[APP_VERSION]-[OS]-custom-[REVISION]` (e.g., `1.27.2-alpine-vhs-custom-1.5.1`); HAProxy uses `[VERSION]-rc[run_number]`
- Registry: GitHub Container Registry (GHCR) primary; Docker Hub as secondary for some services
- Secrets required: `GHCR_TOKEN`; `DOCKER_USERNAME` + `DOCKER_TOKEN` for dual-registry services

#### Local Development

```bash
# Standard startup command (documented in compose headers)
docker-compose up -d --build --force-recreate --remove-orphans

# Build specific version with custom args
docker build -t nqdev/service:tag --build-arg VERSION=x.y.z .
```

## File Naming and Configuration Patterns

### Volume Mounts

- Configuration: `./config` or `./data-etc/[service]/` to the container config path (e.g., `./data-etc/nginx/conf.d/:/etc/nginx/conf.d:rw`)
- Data persistence: `./data-[type]/` pattern (e.g., `./data-log/`, `./data-share/`, `./data-etc/`)
- Logs: Always mount to `./data-log/[service]/` for external access
- Shared assets: `./data-share/GeoIP/`, `./data-share/nginx/`

### Environment Variables

- Use `.env` files for sensitive configuration; provide `.env.sample` alongside each `.env` as a committed template
- Standard variables: `TZ`, `[SERVICE]_USER`, `[SERVICE]_PASSWORD`, `[SERVICE]_PORT`
- Redis integration: `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD` for services using Redis

### Logging Configuration

All compose files include:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "1g"   # or "100m" for lighter services
    max-file: "5"
```

### Security and Resource Management

- Non-root execution where possible (`user: root` only when necessary for entrypoint ownership fix)
- Resource limits in compose files (CPU and memory constraints)
- DNS configuration: Standard public DNS servers (8.8.8.8, 8.8.4.4, 1.1.1.1, 1.0.0.1)

## Common Commands

```bash
# Service management
docker-compose up -d --build --force-recreate --remove-orphans
docker-compose down -v

# Configuration testing (service-specific)
nginx -t                                              # Test NGINX config
haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg     # Test HAProxy config

# Build with version override
docker build --build-arg VERSION=16.4 -t nqdev/postgres-pgagent:16.4 .

# Log monitoring
docker-compose logs -f [service]
```
