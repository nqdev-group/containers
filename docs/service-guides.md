---
layout: default
title: Service Guides
nav_order: 4
has_children: true
---

# Service Guides

Hướng dẫn chi tiết cho từng container service trong NQDEV ecosystem.

## 📦 Available Services

### 🌐 NGINX Container

- **Image**: `nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1`
- **Features**: Custom modules, GeoIP, SSL/TLS, Rate limiting
- **Use cases**: Reverse proxy, Load balancer, Web server

### ⚖️ HAProxy Container

- **Image**: `nqdev/haproxy-alpine-custom:3.1.5`
- **Features**: Lua scripting, Redis integration, SSL termination
- **Use cases**: Load balancing, Traffic management, High availability

### 🗄️ PostgreSQL Container

- **Image**: `postgres:17.5-custom`
- **Features**: pgAgent scheduler, HTTP extension, Job automation
- **Use cases**: Primary database, Scheduled jobs, HTTP requests

### 📱 WordPress Container

- **Image**: WordPress 6.8.3 on Debian 12
- **Features**: PHP 8.4, Apache, SSL ready, WP-CLI
- **Use cases**: CMS, Blog, E-commerce platform

### 🐰 RabbitMQ Container

- **Image**: `bitnamilegacy/rabbitmq:4.1`
- **Features**: Clustering, Management UI, SSL support
- **Use cases**: Message broker, Task queues, Microservices communication

## 🚀 Quick Navigation

Choose the service guide you need:

<div class="grid-container">
  <div class="grid-item">
    <h3><a href="{{ site.baseurl }}/nginx-guide">🌐 NGINX Guide</a></h3>
    <p>Web server với custom modules, rate limiting, và advanced proxy features.</p>
    <ul>
      <li>Custom modules integration</li>
      <li>GeoIP configuration</li>
      <li>SSL/TLS optimization</li>
      <li>Performance tuning</li>
    </ul>
  </div>
  
  <div class="grid-item">
    <h3><a href="{{ site.baseurl }}/haproxy-guide">⚖️ HAProxy Guide</a></h3>
    <p>Load balancer với Lua scripting và Redis rate limiting.</p>
    <ul>
      <li>Lua scripting examples</li>
      <li>Redis integration</li>
      <li>SSL termination</li>
      <li>Health checks</li>
    </ul>
  </div>
</div>

## 🔧 General Service Management

### Start Services

```bash
cd nqdev/[service-name]/
docker-compose up -d --build --force-recreate --remove-orphans
```

### Health Monitoring

```bash
# Check all containers
docker-compose ps

# View logs
docker-compose logs -f [service-name]

# Resource usage
docker stats $(docker-compose ps -q)
```

### Common Troubleshooting

- **Port conflicts**: Check `netstat -tlnp | grep :[port]`
- **Permission issues**: `sudo chown -R 1001:1001 ./data-*`
- **Memory limits**: Adjust in docker-compose.yml
- **Network connectivity**: Verify container networks
