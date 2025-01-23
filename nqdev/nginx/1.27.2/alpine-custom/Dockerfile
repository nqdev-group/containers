ARG NGINX_VERSION=1.27.2
ARG NQDEV_NGINX_REVISION=1.5.1
ARG NQDEV_NGINX_TAG=${NGINX_VERSION}-alpine-vhs-custom-${NQDEV_NGINX_REVISION}

# Sử dụng image nginx:1.27.2-alpine làm base image
FROM nginx:1.27.2-alpine

# Thêm thông tin maintainer
LABEL maintainer="VHS SMS Maintainers <vhs-sms@vihatgroup.com>"

ENV APP_VERSION="${NGINX_VERSION}"
ENV CRONTAB_ENABLE=false
ENV NGINX_HTTP_PORT_NUMBER=80
ENV NGINX_HTTPS_PORT_NUMBER=443
ENV NGINX_STATUS_PORT_NUMBER=8080
# Bổ sung biến môi trường để cấu hình nginx-exporter
ENV NGINX_EXPORTER_ENABLE=false
ENV NGINX_EXPORTER_PORT=9113

# Cài đặt các dependencies cần thiết để cài module bổ sung
RUN apk update && apk add --no-cache \
  build-base \
  pcre-dev \
  openssl-dev \
  zlib-dev \
  git \
  perl \
  wget \
  autoconf \
  automake \
  libtool \
  dcron \
  && rm -rf /var/cache/apk/*

RUN echo "du -h" >> ~/.ash_history \
  echo "nginx -t" >> ~/.ash_history \
  echo "nginx -s reload" >> ~/.ash_history

# Mirror of the LuaJIT git repository
# Cài đặt LuaJIT phiên bản 2.x
RUN wget https://github.com/LuaJIT/LuaJIT/archive/refs/tags/v2.0.ROLLING.tar.gz -O /tmp/luajit2.0.5.tar.gz \
  && tar -xzvf /tmp/luajit2.0.5.tar.gz -C /tmp \
  && cd /tmp/LuaJIT-2.0.ROLLING \
  && make && make install \
  # tell nginx's build system where to find LuaJIT 2.0:
  && echo "export LUAJIT_LIB=/usr/local/lib" >> ~/.bashrc \
  && echo "export LUAJIT_INC=/usr/local/include/luajit-2.0" >> ~/.bashrc \
  # tell nginx's build system where to find LuaJIT 2.1:
  # && echo "export LUAJIT_LIB=/usr/local/lib" >> ~/.bashrc \
  # && echo "export LUAJIT_INC=/usr/local/include/luajit-2.1" >> ~/.bashrc \
  && luajit -v

# Tải và cài đặt module
RUN git clone https://github.com/openresty/headers-more-nginx-module.git /tmp/headers-more-nginx-module \
  # && git clone https://github.com/openresty/lua-nginx-module.git /tmp/lua-nginx-module \
  && git clone https://github.com/weserv/rate-limit-nginx-module.git /tmp/rate-limit-nginx-module \
  && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O /tmp/nginx-${NGINX_VERSION}.tar.gz \
  && tar -xzvf /tmp/nginx-${NGINX_VERSION}.tar.gz -C /tmp \
  && cd /tmp/nginx-${NGINX_VERSION} \
  && ./configure \
  --prefix=/etc/nginx \
  --with-compat \
  --with-mail=dynamic \
  # --add-dynamic-module=/tmp/lua-nginx-module \
  --add-dynamic-module=/tmp/headers-more-nginx-module \
  --add-dynamic-module=/tmp/rate-limit-nginx-module \
  --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
  --with-cc-opt="-I/usr/local/include" \
  && make -j$(nproc) \
  && make modules \
  && make install \
  && cp /tmp/nginx-${NGINX_VERSION}/objs/ngx_http_headers_more_filter_module.so /usr/lib/nginx/modules/ \
  && cp /tmp/nginx-${NGINX_VERSION}/objs/ngx_http_rate_limit_module.so /usr/lib/nginx/modules/ \
  # && cp /tmp/nginx-${NGINX_VERSION}/objs/ngx_http_lua_module.so /usr/lib/nginx/modules/ \
  && rm -rf /tmp/*

# ----- install nginx-exporter ------
# Tải về nginx-exporter
# RUN wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.3.0/nginx-prometheus-exporter_1.3.0_linux_amd64.tar.gz -O /tmp/nginx-prometheus-exporter-1.3.0-linux-amd64.tar.gz \
#   && tar -xzvf /tmp/nginx-prometheus-exporter-1.3.0-linux-amd64.tar.gz -C /usr/local/bin \
#   && mv /usr/local/bin/nginx-prometheus-exporter /usr/local/bin/nginx-exporter \
#   # && rm -f /tmp/nginx-prometheus-exporter-1.3.0-linux-amd64.tar.gz \
#   && rm -rf /usr/local/bin/nginx-prometheus-exporter \
#   && rm -rf /tmp/*

# Tạo thư mục backup nếu chưa có
RUN mkdir -p /var/tmp/nginx/cache \ 
  && mkdir -p /var/backups/nginx_config

# Copy file backup script vào container
# COPY scripts/98-start-nginx-exporter.sh /docker-entrypoint.d/98-start-nginx-exporter.sh
COPY scripts/99-start-cron.sh /docker-entrypoint.d/99-start-cron.sh
COPY scripts/100-backup-nginx.sh /usr/local/bin/100-backup-nginx.sh

# Cấp quyền thực thi cho script
RUN chmod +x /docker-entrypoint.d/ \
  # && chmod +x /docker-entrypoint.d/98-start-nginx-exporter.sh \
  && chmod +x /docker-entrypoint.d/99-start-cron.sh \
  && chmod +x /usr/local/bin/100-backup-nginx.sh

# ----- setup crontabs ------
# Cài đặt cron job để gọi script backup mỗi tuần
RUN echo "0 3 * * 0	/usr/local/bin/100-backup-nginx.sh" >> /etc/crontabs/root
# RUN echo "*/5 * * * *	/usr/local/bin/100-backup-nginx.sh" >> /etc/crontabs/root

# Cấu hình Nginx sẽ sử dụng file cấu hình có sẵn từ project
# COPY base/nginx.conf /etc/nginx/nginx.conf
# Copy toàn bộ nội dung từ thư mục local vào thư mục cấu hình Nginx trong container
COPY base/conf.d/ /etc/nginx/conf.d/
COPY base/include/ /etc/nginx/include/

# Expose port 80 và 443
EXPOSE 80 443
# EXPOSE $NGINX_HTTP_PORT_NUMBER $NGINX_HTTPS_PORT_NUMBER $NGINX_EXPORTER_PORT $NGINX_STATUS_PORT_NUMBER

# Dùng ENTRYPOINT mặc định từ image Nginx để chạy script khởi động của Docker
ENTRYPOINT ["/docker-entrypoint.sh"]

# Xác định tín hiệu dừng container
STOPSIGNAL SIGQUIT

# Start Nginx khi container khởi động
CMD ["nginx", "-g", "daemon off;"]
