## docker-compose.yml

```yml
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Nginx Proxy
# -----------------------------------------
# https://nginx.org/en/docs/
# https://docs.nginx.com/nginx/admin-guide/
# https://www.digitalocean.com/community/tools/nginx
# -----------------------------------------
# https://blog.nginx.org/blog/rate-limiting-nginx
# http://nginx.org/en/docs/http/ngx_http_limit_req_module.html
# http://nginx.org/en/docs/http/ngx_http_proxy_module.html
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# docker-compose up -d --build --force-recreate
services:
  nginx-server:
    # image: nginx:stable-alpine3.20-perl
    image: nqdev/nginx:1.27.2-alpine-custom-r1.3
    build:
      context: ./ # Path to your application's Dockerfile
      dockerfile: ./Dockerfile
    container_name: nginx-server
    restart: always
    user: root
    # network_mode: "host"
    ports:
      - "32768:80" # Cổng HTTP để Certbot xác thực
      # - "443:443" # Cổng HTTPS cho Nginx sử dụng chứng chỉ SSL
      - "18080:8080"
    environment:
      TZ: Asia/Ho_Chi_Minh
      NGINX_HTTP_PORT_NUMBER: 80
      NGINX_HTTPS_PORT_NUMBER: 443
      CRONTAB_ENABLE: true # enable crontab
      # NGINX_EXPORTER_ENABLE: false # enable nginx-exporter
      # NGINX_EXPORTER_PORT: 9113
    volumes:
      - ./data/etc/nginx/nginx.conf:/etc/nginx/nginx.conf:rw
      - ./data/etc/nginx/conf.d/:/etc/nginx/conf.d:rw
      - ./data/etc/nginx/njs/:/etc/nginx/njs:rw
      - ./data/etc/nginx/stream.d/:/etc/nginx/stream.d:rw
      - ./data/log/nginx/:/var/log/nginx:rw
      # - ./data/backups/nginx:/var/backups/nginx_config:rw
      - ./data/share/GeoIP/:/usr/share/GeoIP:rw
      - ./data/share/nginx/:/usr/share/nginx:rw
    extra_hosts:
      - "esms-logstash-1:192.168.2.53"
      - "esms-proxy-1:192.168.2.60"
      - "esms-global-proxy-1:192.168.2.68"
      - "esms-asterisk-1:192.168.2.74"
      - "local-nqdev:127.0.0.1"
    dns:
      - 8.8.8.8
      - 8.8.4.4
      - 1.1.1.1
      - 1.0.0.1
    logging:
      driver: "json-file"
      options:
        max-size: "1g"
    deploy:
      resources:
        limits:
          cpus: "0.80" # Giới hạn 80% CPU
          memory: "3.2G" # Giới hạn 3.2GB RAM (80% của 4GB)
        reservations:
          cpus: "0.25" # Đảm bảo container có ít nhất 25% CPU
          memory: "256M" # Đảm bảo container có ít nhất 256MB RAM
    depends_on:
      - nginx-certbot

  # Dịch vụ Certbot
  # docker-compose run --rm nginx-certbot certonly --webroot --webroot-path=/var/www/certbot -d nhquydev.net
  nginx-certbot:
    image: certbot/certbot:nightly
    container_name: nginx-certbot
    restart: always
    user: root
    volumes:
      # - ./data/opt/certbot:/opt/certbot/:rw
      - ./data/etc/letsencrypt/:/etc/letsencrypt/:rw # Lưu trữ chứng chỉ SSL
      # - ./data/lib/letsencrypt:/var/lib/letsencrypt:rw
      - ./data/log/letsencrypt:/var/log/letsencrypt:rw
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
    environment:
      TZ: Asia/Ho_Chi_Minh
    extra_hosts:
      - "esms-logstash-1:192.168.2.53"
      - "esms-proxy-1:192.168.2.60"
      - "esms-global-proxy-1:192.168.2.68"
      - "esms-asterisk-1:192.168.2.74"
      - "local-nqdev:127.0.0.1"
    dns:
      - 8.8.8.8
      - 8.8.4.4
      - 1.1.1.1
      - 1.0.0.1
    logging:
      driver: "json-file"
      options:
        max-size: "1g"

  nginx-exporter:
    # image: nginx/nginx-prometheus-exporter:0.8.0
    image: nginx/nginx-prometheus-exporter:latest
    container_name: nginx-exporter
    restart: always
    environment:
      TZ: Asia/Ho_Chi_Minh
      SCRAPE_URI: http://nginx-server:80/nginx_status # Endpoint để scrape dữ liệu
      LISTEN_PORT: 9113 # Cổng để Prometheus scrape
    # network_mode: "host"
    ports:
      - "9113:9113"
    command:
      - -nginx.scrape-uri
      - http://127.0.0.1:8080/nginx_status
    extra_hosts:
      - "esms-logstash-1:192.168.2.53"
      - "esms-proxy-1:192.168.2.60"
      - "esms-global-proxy-1:192.168.2.68"
      - "esms-asterisk-1:192.168.2.74"
      - "local-nqdev:127.0.0.1"
    dns:
      - 8.8.8.8
      - 8.8.4.4
      - 1.1.1.1
      - 1.0.0.1
    logging:
      driver: "json-file"
      options:
        max-size: "1g"
    depends_on:
      - nginx-server
```

## 00-startup.sh

```bash
#!/bin/bash
container_name=$1

docker-compose up -d --build --force-recreate --timestamps
```

## 01-verify-config.sh

```bash
#!/bin/bash
container_name='nginx-server'

if [ "$1" = "vm74" ]; then
    container_name='nginx-server-vm74'
elif [ "$1" = "vm60" ]; then
    container_name='nginx-server-vm60'
else
    echo 0
fi

echo $container_name
docker exec $container_name nginx -t

exit 0
```

## 02-reload-config.sh

```bash
#!/bin/bash
container_name='nginx-server'

if [ "$1" = "vm74" ]; then
    container_name='nginx-server-vm74'
elif [ "$1" = "vm60" ]; then
    container_name='nginx-server-vm60'
else
    echo 0
fi

echo $container_name
docker exec $container_name nginx -s reload

exit 0
```
