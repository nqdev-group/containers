# Sử dụng Ubuntu làm base image
FROM ubuntu:20.04

# Cập nhật package list và cài đặt các package cần thiết
RUN apt-get update && apt-get install -y \
  curl \
  sudo \
  tar \
  git \
  unzip \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Tạo thư mục cho runner
RUN mkdir -p /actions-runner
WORKDIR /actions-runner

# Tải và giải nén package runner
RUN curl -o actions-runner-linux-x64-2.329.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz && \
  tar xzf ./actions-runner-linux-x64-2.329.0.tar.gz && \
  rm -f actions-runner-linux-x64-2.329.0.tar.gz

# Thêm script chạy runner và cấu hình (chạy thông qua entrypoint)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Cấu hình runner (token cần phải được truyền vào từ environment variables)
ENTRYPOINT ["/entrypoint.sh"]
