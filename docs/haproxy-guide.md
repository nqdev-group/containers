---
layout: default
title: HAProxy Container Guide
parent: Service Guides
nav_order: 2
---

# HAProxy Container - Hướng dẫn sử dụng chi tiết

![HAProxy](https://img.shields.io/badge/haproxy-3.1.5-blue)
![Lua](https://img.shields.io/badge/lua-5.4-orange)
![Redis](https://img.shields.io/badge/redis-integration-red)

## 📋 Thông tin cơ bản

- **Image**: `nqdev/haproxy-alpine-custom:3.1.5`
- **Base**: Alpine Linux
- **HAProxy Version**: 3.1.5
- **Lua Version**: 5.4
- **Redis Integration**: ✅

## 🚀 Khởi động nhanh

```bash
# Di chuyển vào thư mục HAProxy
cd nqdev/haproxy/alpine

# Khởi chạy container
docker-compose up -d --build --force-recreate --remove-orphans

# Kiểm tra trạng thái
curl http://localhost:18080
open http://localhost:17001  # Stats dashboard
```

## 🧱 Tính năng nổi bật

### Core Features

- **Lua 5.4 Scripting**: Advanced logic và custom functions
- **Redis Rate Limiting**: Phân tán rate limiting với Redis backend
- **CIDR IP Filtering**: Whitelist/blacklist theo IP ranges
- **SSL/TLS Termination**: Modern cipher suites
- **HTTP/2 Support**: High-performance HTTP/2 protocol

### Advanced Features

- **Custom Error Pages**: Professional error handling
- **Real-time Stats**: Dashboard với metrics chi tiết
- **Health Checks**: Automatic failover
- **Compression**: Static asset compression
- **Structured Logging**: JSON format logs
- **Load Balancing**: Multiple algorithms (roundrobin, leastconn, random)

## ⚙️ Cấu hình

### Environment Variables

| Variable         | Default            | Description                   |
| ---------------- | ------------------ | ----------------------------- |
| `TZ`             | `Asia/Ho_Chi_Minh` | Container timezone            |
| `REDIS_HOST`     | `127.0.0.1`        | Redis server hostname         |
| `REDIS_PORT`     | `6379`             | Redis server port             |
| `REDIS_PASSWORD` | _empty_            | Redis authentication password |

### Port Mapping

| Container Port | Host Port | Service            |
| -------------- | --------- | ------------------ |
| 80             | 18080     | HTTP Load Balancer |
| 7001           | 17001     | Stats Dashboard    |

### Volume Mounts

```yaml
volumes:
  - ./haproxy:/usr/local/etc/haproxy:rw
```

## 📁 Cấu trúc file

### HAProxy Configuration Structure

```
/usr/local/etc/haproxy/
├── haproxy.cfg              # Main configuration file

/nqdev/haproxy/               # NQDEV custom structure
├── lua/                      # Lua scripts
│   ├── redis_connector.lua   # Redis utilities
│   ├── redis_rate_limit.lua  # Rate limiting logic
│   └── cidr_check.lua       # IP/CIDR functions
├── map/                      # Map files
│   └── ipclient-rates.map   # IP-specific rates
└── errorfiles/               # Custom error pages
    ├── 400.http, 403.http
    ├── 404.http, 408.http
    ├── 429.http, 500.http
    ├── 502.http, 503.http
    └── 504.http
```

### Lua Libraries

- **LuaSocket 3.1.0**: Network communication
- **Redis-Lua 2.0.4**: Redis client
- **LuaRocks 3.9.2**: Package manager

## 🔧 Cấu hình nâng cao

### 1. Rate Limiting System

#### Map Configuration (`/nqdev/haproxy/map/ipclient-rates.map`)

```
# Format: IP/CIDR    requests_per_minute
192.168.1.0/24      100    # Local network - 100 req/min
10.0.0.0/8          50     # VPN users - 50 req/min
203.113.0.0/16      30     # Specific ISP - 30 req/min
0.0.0.0/0          10     # Default - 10 req/min
```

#### HAProxy Configuration

```haproxy
# Rate limiting section
frontend http_in
    bind *:80

    # Rate limiting check
    http-request lua.action_ratelimit_req_check

    # Deny if rate limit exceeded
    http-request deny if { var(txn.is_rate_limit_reject_req) -m str true }

    default_backend web_backend
```

#### Lua Rate Limiting Script

```lua
-- /nqdev/haproxy/lua/redis_rate_limit.lua
function rate_limit_check(client_ip, txn)
    local redis = require("redis")
    local client = redis.connect('127.0.0.1', 6379)

    -- Get rate limit for IP from map
    local rate_limit = get_rate_limit_for_ip(client_ip)

    -- Check current usage
    local key = "rate_limit:" .. client_ip
    local current = client:get(key)

    if current and tonumber(current) >= rate_limit then
        return false  -- Rate limit exceeded
    end

    -- Increment counter
    client:incr(key)
    client:expire(key, 60)  -- 1 minute window

    return true  -- Allow request
end
```

### 2. SSL/TLS Configuration

```haproxy
# Frontend with SSL termination
frontend https_in
    bind *:443 ssl crt /etc/ssl/certs/server.pem alpn h2,http/1.1

    # Security headers
    http-after-response set-header Strict-Transport-Security "max-age=31536000"
    http-response del-header server
    http-response del-header x-powered-by

    default_backend secure_backend

# SSL redirect
frontend http_redirect
    bind *:80
    redirect scheme https code 301
```

### 3. Load Balancing Algorithms

```haproxy
# Round Robin (default)
backend web_backend_rr
    balance roundrobin
    server web1 192.168.1.100:8080 check
    server web2 192.168.1.101:8080 check
    server web3 192.168.1.102:8080 check

# Least Connections
backend web_backend_lc
    balance leastconn
    server web1 192.168.1.100:8080 check
    server web2 192.168.1.101:8080 check

# Source IP hash
backend web_backend_source
    balance source
    hash-type consistent
    server web1 192.168.1.100:8080 check
    server web2 192.168.1.101:8080 check

# Random
backend web_backend_random
    balance random
    server web1 192.168.1.100:8080 check
    server web2 192.168.1.101:8080 check
```

### 4. Health Checks

```haproxy
backend web_backend
    # HTTP health check
    option httpchk OPTIONS / HTTP/1.0
    http-check expect rstatus (2|3)[0-9][0-9]

    # Advanced health check
    http-check send meth GET uri /health ver HTTP/1.1 hdr host api.example.com
    http-check expect status 200
    http-check expect string "healthy"

    # Server definitions with health monitoring
    server web1 192.168.1.100:8080 check inter 2s rise 2 fall 3 maxconn 500
    server web2 192.168.1.101:8080 check inter 2s rise 2 fall 3 maxconn 500 backup
```

### 5. Advanced Routing

```haproxy
frontend advanced_routing
    bind *:80

    # Host-based routing
    acl is_api hdr(host) -i api.example.com
    acl is_admin hdr(host) -i admin.example.com

    # Path-based routing
    acl is_api_v1 path_beg /api/v1
    acl is_api_v2 path_beg /api/v2

    # Geographic routing (with GeoIP)
    acl is_vietnam src_cc VN
    acl is_asia src_cc JP KR TH SG

    # Route to appropriate backends
    use_backend api_v1_backend if is_api is_api_v1
    use_backend api_v2_backend if is_api is_api_v2
    use_backend admin_backend if is_admin
    use_backend asia_backend if is_asia
    use_backend vietnam_backend if is_vietnam

    default_backend default_backend
```

## 📊 Monitoring & Stats

### Stats Dashboard

**URL**: http://localhost:17001  
**Credentials**: admin:UaA84JvFZzNW

#### Dashboard Features

- Real-time connection metrics
- Backend server status
- Request/response statistics
- Error rates và response times
- Server health indicators

### Rate Limiting Headers

HAProxy tự động thêm headers để client tracking:

```http
x-ratelimit-limit: 100
x-ratelimit-usage: 23
x-ratelimit-remaining: 77
x-ratelimit-retry-after: 60
x-ratelimit-timestamp: 1699891200
```

### Structured Logging

```haproxy
# JSON format logging
log-format "{\"type\":\"haproxy\",\"timestamp\":%Ts,\"frontend\":\"%f\",\"client_ip\":\"%ci\",\"status\":%ST,\"response_time\":%Tr,\"backend\":\"%b/%s\"}"
```

Example log output:

```json
{
  "type": "haproxy",
  "timestamp": 1699891200,
  "frontend": "http_in",
  "client_ip": "192.168.1.100",
  "status": 200,
  "response_time": 45,
  "backend": "web_backend/server1"
}
```

## 🔧 Lua Scripting

### 1. Redis Connector

```lua
-- /nqdev/haproxy/lua/redis_connector.lua
local redis = require("redis")

function connect_redis()
    local host = os.getenv("REDIS_HOST") or "127.0.0.1"
    local port = tonumber(os.getenv("REDIS_PORT")) or 6379
    local password = os.getenv("REDIS_PASSWORD")

    local client = redis.connect(host, port)

    if password and password ~= "" then
        client:auth(password)
    end

    return client
end

function redis_get(key)
    local client = connect_redis()
    local result = client:get(key)
    client:close()
    return result
end

function redis_set(key, value, ttl)
    local client = connect_redis()
    client:set(key, value)
    if ttl then
        client:expire(key, ttl)
    end
    client:close()
end
```

### 2. CIDR Matching

```lua
-- /nqdev/haproxy/lua/cidr_check.lua
function ip_to_int(ip_str)
    local parts = {}
    for part in ip_str:gmatch("(%d+)") do
        table.insert(parts, tonumber(part))
    end
    return parts[1] * 16777216 + parts[2] * 65536 + parts[3] * 256 + parts[4]
end

function cidr_match(ip, cidr)
    local ip_addr, prefix = cidr:match("([^/]+)/(%d+)")

    if not ip_addr or not prefix then
        return false
    end

    local ip_int = ip_to_int(ip)
    local cidr_int = ip_to_int(ip_addr)
    local mask = bit32.lshift(0xFFFFFFFF, 32 - tonumber(prefix))

    return bit32.band(ip_int, mask) == bit32.band(cidr_int, mask)
end

-- Check if IP is in allowed CIDR ranges
function is_ip_allowed(ip, allowed_cidrs)
    for _, cidr in ipairs(allowed_cidrs) do
        if cidr_match(ip, cidr) then
            return true
        end
    end
    return false
end
```

### 3. Dynamic Response Generation

```lua
-- Service cho rate limit rejection
core.register_service("action_ratelimit_check_deny_429", "http", function(applet)
    applet:set_status(429)
    applet:add_header("content-type", "application/json")
    applet:add_header("retry-after", "60")

    local client_ip = applet.sf:src()
    local response = string.format('{"status":429,"message":"Too Many Requests","client_ip":"%s","retry_after":60}', client_ip)

    applet:start_response()
    applet:send(response)
end)
```

## 🛠️ Management & Testing

### Configuration Testing

```bash
# Test HAProxy configuration
docker-compose exec haproxy-server-custom haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

# Test Lua scripts syntax
docker-compose exec haproxy-server-custom lua /nqdev/haproxy/lua/redis_rate_limit.lua

# Reload configuration without downtime
docker-compose exec haproxy-server-custom haproxy -D -f /usr/local/etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)
```

### Rate Limiting Test

```bash
# Test rate limiting với curl
for i in {1..15}; do
  curl -H "Host: example.com" http://localhost:18080/ \
    -w "Request $i: HTTP %{http_code}, Time: %{time_total}s\n" \
    -o /dev/null -s
  sleep 0.1
done
```

### Load Testing

```bash
# Apache Bench test
ab -n 1000 -c 50 -H "Host: api.example.com" http://localhost:18080/

# wrk test
wrk -t4 -c50 -d30s --timeout 2s http://localhost:18080/
```

### Redis Connectivity Test

```bash
# Test Redis connection from HAProxy
docker-compose exec haproxy-server-custom lua -e "
local redis = require('redis')
local client = redis.connect('$REDIS_HOST', $REDIS_PORT)
print('Redis connection: OK')
client:close()
"
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Backend servers unavailable

```bash
# Check backend status in stats
curl http://admin:UaA84JvFZzNW@localhost:17001/;csv

# Manual health check
curl -I http://192.168.1.100:8080/health
```

#### 2. Rate limiting not working

```bash
# Check Redis connectivity
docker-compose exec haproxy-server-custom redis-cli -h $REDIS_HOST ping

# Debug rate limit script
docker-compose logs haproxy-server-custom | grep "rate.*limit"
```

#### 3. SSL issues

```bash
# Test SSL certificate
openssl s_client -connect localhost:443 -servername example.com

# Check certificate expiry
openssl x509 -in /path/to/cert.pem -text -noout | grep "Not After"
```

#### 4. Performance issues

```bash
# Monitor connection stats
watch -n 1 'curl -s http://admin:UaA84JvFZzNW@localhost:17001/;csv | head -1'

# Check system resources
docker stats haproxy-server-custom
```

### Debug Commands

```bash
# Container logs với filtering
docker-compose logs haproxy-server-custom | grep -E "(ERROR|WARN|rate.*limit)"

# HAProxy process info
docker-compose exec haproxy-server-custom ps aux | grep haproxy

# Network connectivity
docker-compose exec haproxy-server-custom netstat -tlnp

# Configuration dump
docker-compose exec haproxy-server-custom haproxy -vv
```

## 🚀 Production Deployment

### High Availability Setup

```yaml
# docker-compose.prod.yml
version: "3.8"

services:
  haproxy-primary:
    image: nqdev/haproxy-alpine-custom:3.1.5
    environment:
      - REDIS_HOST=redis-cluster-primary
      - REDIS_PORT=6379
    networks:
      - frontend
      - backend
    deploy:
      placement:
        constraints: [node.role == manager]

  haproxy-backup:
    image: nqdev/haproxy-alpine-custom:3.1.5
    environment:
      - REDIS_HOST=redis-cluster-backup
      - REDIS_PORT=6379
    networks:
      - frontend
      - backend
    deploy:
      placement:
        constraints: [node.role == worker]

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay
```

### Performance Tuning

```haproxy
global
    # Process optimization
    nbproc 4                    # CPU cores
    nbthread 2                  # Threads per process

    # Connection limits
    maxconn 50000
    ulimit-n 100050

    # Memory tuning
    tune.bufsize 32768
    tune.maxrewrite 8192

    # SSL optimization
    ssl-default-bind-ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384
    tune.ssl.default-dh-param 2048

defaults
    # Timeouts
    timeout client 120s
    timeout server 120s
    timeout http-keep-alive 10s
    timeout http-request 10s

    # Connection optimization
    option http-keep-alive
    option forwardfor
```

### Security Configuration

```haproxy
# DDoS protection
frontend ddos_protection
    # Connection rate limiting
    stick-table type ip size 100k expire 30s store http_req_rate(10s)
    http-request track-sc0 src
    http-request deny if { sc_http_req_rate(0) gt 20 }

    # Block suspicious patterns
    acl abuse_req url_reg -i (\.php|admin|phpmyadmin)
    http-request deny if abuse_req

    # Geographic restrictions
    acl blocked_countries src_cc CN RU
    http-request deny if blocked_countries
```

## 📚 Examples

### Example 1: API Gateway

```haproxy
# API Gateway configuration
frontend api_gateway
    bind *:80

    # Authentication check
    acl has_auth_header req.hdr(Authorization) -m found
    http-request deny if !has_auth_header

    # Rate limiting per API key
    http-request lua.extract_api_key
    stick-table type string len 32 size 10k expire 60s store http_req_rate(60s)
    http-request track-sc0 var(txn.api_key) table api_rate_limit
    http-request deny if { sc_http_req_rate(0,api_rate_limit) gt 1000 }

    # Route to services
    acl is_user_service path_beg /users
    acl is_order_service path_beg /orders

    use_backend user_service if is_user_service
    use_backend order_service if is_order_service

backend user_service
    balance roundrobin
    option httpchk GET /health
    server user1 user-service-1:8080 check
    server user2 user-service-2:8080 check

backend order_service
    balance leastconn
    option httpchk GET /health
    server order1 order-service-1:8080 check
    server order2 order-service-2:8080 check
```

### Example 2: Blue-Green Deployment

```haproxy
# Blue-Green deployment setup
frontend blue_green_frontend
    bind *:80

    # Traffic switching via header/cookie
    acl is_canary_user hdr(X-Canary-User) -m str true
    acl has_canary_cookie cook(canary) -m str enabled

    use_backend green_backend if is_canary_user or has_canary_cookie
    default_backend blue_backend

backend blue_backend
    # Current production
    server prod1 prod-v1-1:8080 check
    server prod2 prod-v1-2:8080 check

backend green_backend
    # New version
    server staging1 prod-v2-1:8080 check
    server staging2 prod-v2-2:8080 check
```

### Example 3: WebSocket Load Balancing

```haproxy
# WebSocket support with sticky sessions
frontend websocket_frontend
    bind *:80

    # WebSocket detection
    acl is_websocket hdr(Upgrade) -i websocket
    acl is_websocket path_beg /ws

    use_backend websocket_backend if is_websocket

backend websocket_backend
    # Sticky sessions for WebSocket
    balance source
    hash-type consistent

    # WebSocket timeout
    timeout tunnel 3600s

    server ws1 websocket-1:8080 check
    server ws2 websocket-2:8080 check
```

---

## 📞 Support

- **Documentation**: [HAProxy 3.1 Guide](https://docs.haproxy.org/3.1/intro.html)
- **Lua API**: [HAProxy Lua API](https://www.arpalert.org/src/haproxy-lua-api/3.1/index.html)
- **Issues**: [GitHub Issues](https://github.com/nqdev-group/containers/issues)

---

**NQDEV Team** - Platform Engineering  
📧 quynh@nhquydev.net | 🌐 [nhquydev.net](https://nhquydev.net)
