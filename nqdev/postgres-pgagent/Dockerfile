# Sử dụng PostgreSQL làm base image
# https://hub.docker.com/_/postgres
# Phiên bản PostgreSQL mặc định là 17.5 (17) tính đến tháng 6 năm 2024
# Có thể thay đổi phiên bản PostgreSQL bằng cách thiết lập biến môi trường VERSION khi build image

ARG VERSION=17.5

FROM postgres:${VERSION} as builder

# Cài đặt các package cần thiết và tối ưu hóa kích thước
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  postgresql-server-dev-17 \
  pgagent \
  build-essential \
  git \
  libcurl4-openssl-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/pramsey/pgsql-http.git /pgsql-http && cd /pgsql-http && make && make install

FROM postgres:${VERSION}

# Thêm metadata labels
LABEL org.opencontainers.image.title="PostgreSQL with Extensions" \
  org.opencontainers.image.version="1.0" \
  org.opencontainers.image.description="PostgreSQL with pgagent, http extension, and dev tools" \
  org.opencontainers.image.authors="QuyIT Platform <quynh@nhquydev.net>" \
  org.opencontainers.image.licenses="MIT"

ENV TIMEZONE=Asia/Ho_Chi_Minh

# Cài đặt các package cần thiết và tối ưu hóa kích thước
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  tzdata \
  postgresql-server-dev-17 \
  pgagent \
  build-essential \
  git \
  libcurl4-openssl-dev && \
  ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /pgsql-http/ /usr/local/pgsql-http/
RUN cp /usr/local/pgsql-http/http.so /usr/lib/postgresql/17/lib/

# Tạo các thư mục cần thiết
RUN mkdir -p /nqdev/postgres/docker-entrypoint-initdb.d && \
  mkdir -p /nqdev/postgres/scripts && \
  mkdir -p /nqdev/postgres/data && \
  mkdir -p /nqdev/postgres/logs

VOLUME ["/nqdev/postgres/data", "/nqdev/postgres/logs"]

# Sao chép các file khởi tạo và script vào container
COPY scripts/ /nqdev/postgres/scripts/
COPY docker-entrypoint-initdb.d/ /nqdev/postgres/docker-entrypoint-initdb.d/

RUN chmod +x /nqdev/postgres/scripts/*.sh
RUN chmod +x /nqdev/postgres/scripts/00-init-custom.sh && \
  ln -s /nqdev/postgres/scripts/00-init-custom.sh /docker-entrypoint-initdb.d/00-init-custom.sh

# Xác định tín hiệu dừng container
STOPSIGNAL SIGQUIT

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["postgres"]
