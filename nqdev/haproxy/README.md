# NQDEV HAProxy + Lua + Redis Container

![Docker](https://img.shields.io/badge/docker-haproxy-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/haproxy-3.1.5-blue)
![Lua](https://img.shields.io/badge/lua-5.4-orange)

Đây là container HAProxy tùy chỉnh với Lua scripting và Redis integration, được phát triển bởi NQDEV team. Container này cung cấp load balancing, rate limiting, SSL termination và advanced traffic management.

## 🚀 Khởi động nhanh

```bash
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
docker-compose up -d --build --force-recreate --remove-orphans
```

## 🧱 Thành phần & Tính năng

### Core Components

- **HAProxy 3.1.5**: High-performance TCP/HTTP load balancer
- **Lua 5.4**: Scripting engine cho advanced logic
- **Redis Integration**: Rate limiting và session management
- **Alpine Linux**: Base image tối ưu về kích thước

### Advanced Features

- ✅ **Lua-based Rate Limiting** với Redis backend
- ✅ **CIDR IP Filtering** cho whitelist/blacklist
- ✅ **HTTP/2 & SSL/TLS Support** với modern ciphers
- ✅ **Custom Error Pages** cho tất cả HTTP status codes
- ✅ **Real-time Stats Dashboard** trên port 7001
- ✅ **HTTP Caching** với 200MB cache instance
- ✅ **Compression** cho static assets
- ✅ **Health Checks** với auto-failover
- ✅ **Structured Logging** với JSON format

## 📦 Build & Deployment

### Build với Redis integration

```bash
# Build container
docker build -t nqdev/haproxy-alpine-custom:3.1.5 .

# Kiểm tra Lua modules
docker run --rm nqdev/haproxy-alpine-custom:3.1.5 luarocks list
```

### Docker Compose (Khuyến nghị)

```yaml
# # # # # HAProxy - The Reliable, High Performance TCP/HTTP Load Balancer
# START: docker-compose up -d --build --force-recreate --remove-orphans
# STOP: docker-compose down -v
# # # # #

services:
  haproxy-server-custom:
    container_name: haproxy-server-custom
    image: nqdev/haproxy-alpine-custom:3.1.5-rc10
    build:
      context: ./
      dockerfile: ./Dockerfile
    ports:
      - "18080:80" # HTTP port
      - "17001:7001" # Stats dashboard
    environment:
      - TZ=Asia/Ho_Chi_Minh
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
      - REDIS_PASSWORD=${REDIS_PASSWORD}
    volumes:
      - ./haproxy:/usr/local/etc/haproxy:rw
    dns:
      - 8.8.8.8
      - 8.8.4.4
      - 1.1.1.1
      - 1.0.0.1
    deploy:
      resources:
        limits:
          cpus: "0.80"
          memory: "3.2G"
        reservations:
          cpus: "0.25"
          memory: "256M"
```

### Standalone Docker

```bash
docker run -d \
  --name haproxy-server-custom \
  -p 18080:80 \
  -p 17001:7001 \
  -e TZ=Asia/Ho_Chi_Minh \
  -e REDIS_HOST=redis-server \
  -e REDIS_PORT=6379 \
  -v ./haproxy:/usr/local/etc/haproxy:rw \
  nqdev/haproxy-alpine-custom:3.1.5
```

## 🗂️ Cấu trúc Container

### Thư mục chính

```
/usr/local/etc/haproxy/               # HAProxy configuration
├── haproxy.cfg                       # Main configuration file

/nqdev/haproxy/                       # NQDEV custom structure
├── lua/                              # Lua scripts
│   ├── redis_connector.lua           # Redis connection utility
│   ├── redis_rate_limit.lua          # Rate limiting logic
│   └── cidr_check.lua               # IP/CIDR matching functions
├── map/                              # Map files
│   └── ipclient-rates.map           # IP-specific rate limits
└── errorfiles/                       # Custom error pages
    ├── 400.http, 403.http, 404.http
    ├── 408.http, 429.http, 500.http
    ├── 502.http, 503.http, 504.http
    └── README
```

### Lua Libraries Installed

- **LuaSocket 3.1.0**: Network communication
- **Redis-Lua 2.0.4**: Redis client library
- **LuaRocks 3.9.2**: Package manager

## 🎛️ Configuration Features

### Rate Limiting System

```lua
-- Map file: /nqdev/haproxy/map/ipclient-rates.map
192.168.1.0/24    100    # Local network - 100 req/min
10.0.0.0/8        50     # VPN users - 50 req/min
0.0.0.0/0         10     # Default - 10 req/min
```

### SSL/TLS Configuration

```bash
# Supported protocols and ciphers
ssl crt /etc/haproxy/ssl/ alpn h2,http/1.1 no-sslv3 no-tlsv10 no-tlsv11

# HSTS header (1 year)
http-after-response set-header Strict-Transport-Security "max-age=31536000"
```

### Load Balancing Algorithms

- **roundrobin**: Tốt cho short requests
- **leastconn**: Tốt cho mixed slow requests
- **random**: Tốt khi sử dụng multiple load balancers

### Health Checks

```haproxy
# HTTP health check với expected status
option httpchk OPTIONS / HTTP/1.0
http-check expect rstatus (2|3)[0-9][0-9]
```

## 📊 Monitoring & Stats

### Stats Dashboard

- **URL**: http://localhost:17001/
- **Auth**: admin:UaA84JvFZzNW
- **Features**: Real-time metrics, server health, traffic stats

### Structured Logging

```json
{
  "type": "haproxy",
  "timestamp": 1699891200,
  "frontend_name": "http_in",
  "client_ip": "192.168.1.100",
  "status_code": 200,
  "response_time": 45,
  "backend_server": "web_backend/server1"
}
```

### Rate Limiting Headers

```http
x-ratelimit-limit: 100
x-ratelimit-usage: 23
x-ratelimit-remaining: 77
x-ratelimit-retry-after: 60
x-ratelimit-timestamp: 1699891200
```

## 🔧 Lua Scripting Features

### Redis Rate Limiting

```lua
-- Kiểm tra rate limit cho IP
core.register_action("action_ratelimit_req_check", { "http-req" }, function(txn)
  local client_ip = get_client_ip(txn)
  local rate_limit_ok = rate_limit_check(client_ip, txn)

  if not rate_limit_ok then
    txn:set_var("txn.is_rate_limit_reject_req", "true")
  end
end)
```

### CIDR IP Matching

```lua
-- Kiểm tra IP trong CIDR range
if cidr_match("192.168.1.100", "192.168.1.0/24") then
  -- IP thuộc về local network
  allow_request()
end
```

### Dynamic Response Generation

```lua
-- Service trả về 429 Too Many Requests
core.register_service("action_ratelimit_check_deny_429", "http", function(applet)
  applet:set_status(429)
  applet:add_header("content-type", "application/json")

  local response = '{"status":"429","message":"Too Many Requests"}'
  applet:start_response()
  applet:send(response)
end)
```

## ⚙️ Biến môi trường

| Biến             | Mặc định           | Mô tả                         |
| ---------------- | ------------------ | ----------------------------- |
| `REDIS_HOST`     | `127.0.0.1`        | Redis server hostname         |
| `REDIS_PORT`     | `6379`             | Redis server port             |
| `REDIS_PASSWORD` | _empty_            | Redis authentication password |
| `TZ`             | `Asia/Ho_Chi_Minh` | Container timezone            |

## 🔍 Health Checks & Testing

### Configuration Validation

```bash
# Test HAProxy configuration
docker exec haproxy-server-custom haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

# Check Lua scripts syntax
docker exec haproxy-server-custom lua -l /nqdev/haproxy/lua/redis_rate_limit.lua
```

### Rate Limiting Test

```bash
# Test rate limiting với curl
for i in {1..15}; do
  curl -H "Host: nqdev.local" http://localhost:18080/ \
    -w "Request $i: %{http_code}\n" -o /dev/null -s
done
```

### Redis Connection Test

```bash
# Kiểm tra Redis connectivity
docker exec haproxy-server-custom lua /nqdev/haproxy/lua/redis_connector.lua
```

## 🔒 Security Features

### IP Whitelisting/Blacklisting

```haproxy
# Whitelist files
acl whitelist           src -f /etc/haproxy/whitelist.lst
acl whitelist_webadmin  src -f /etc/haproxy/whitelist-webadmin.lst

# Apply restrictions
http-request deny unless whitelist
```

### SSL Security Headers

```haproxy
# Security headers
http-after-response set-header Strict-Transport-Security "max-age=31536000"
http-response del-header server
http-response del-header x-powered-by
```

### Rate Limiting per IP/CIDR

- Support cho individual IP addresses
- CIDR range matching (192.168.1.0/24)
- Redis-based counting với TTL
- Configurable limits per IP range

## 📋 Backend Configuration

### Server Definitions

```haproxy
backend backend_maintenance_server
    balance random
    cookie backend_maintenance_server insert indirect nocache

    # Compression
    filter compression
    compression algo gzip
    compression type text/css text/html application/javascript

    # Health checks
    option httpchk OPTIONS / HTTP/1.0
    http-check expect rstatus (2|3)[0-9][0-9]

    # Servers with health monitoring
    server host1 192.168.2.78:17007 cookie s1 minconn 50 maxconn 500 check inter 1s
```

### Advanced Routing

- **Host-based routing**: Dựa trên header Host
- **Path-based routing**: Dựa trên URL path
- **SSL/non-SSL routing**: Dựa trên ssl_fc
- **Geographic routing**: Dựa trên GeoIP (nếu enable)

## 🚀 Production Deployment

### High Availability Setup

```yaml
# docker-compose.prod.yml
services:
  haproxy-primary:
    image: nqdev/haproxy-alpine-custom:3.1.5
    environment:
      REDIS_HOST: redis-cluster
    networks:
      - frontend
      - backend

  haproxy-backup:
    image: nqdev/haproxy-alpine-custom:3.1.5
    environment:
      REDIS_HOST: redis-cluster
    networks:
      - frontend
      - backend
```

### Performance Tuning

```haproxy
global
    maxconn       50000
    ulimit-n      100050

defaults
    maxconn                 50000
    timeout client          120000ms
    timeout server          120000ms
    timeout http-keep-alive 5m
```

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

## 👨‍💻 Maintainer

**NQDEV Team**

- 📧 Email: quynh@nhquydev.net
- 🌐 Website: [nhquydev.net](https://nhquydev.net)
- 📦 Container Registry: [GitHub Packages](https://github.com/nqdev-group/containers/pkgs/container/haproxy-alpine-custom)
- 📖 HAProxy Documentation: [HAProxy 3.1 Guide](https://docs.haproxy.org/3.1/intro.html)
