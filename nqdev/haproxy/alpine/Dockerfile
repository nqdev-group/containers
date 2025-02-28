
# Bắt đầu từ base image HAProxy Alpine
FROM haproxytech/haproxy-alpine:3.1.5

# Thêm thông tin maintainer
LABEL maintainer="QuyIT Platform <quynh@nhquydev.net>"

# Cài đặt các công cụ cần thiết, bao gồm Lua 5.4 và các thư viện liên quan
RUN apk update && \
  apk add --no-cache \
  lua5.4 \
  lua5.4-dev \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  bash \
  curl \
  unzip \
  tar \
  git && rm -rf /var/cache/apk/*

# Tạo liên kết tượng trưng (symlink) để `lua` trỏ tới `lua5.4`
RUN ln -s /usr/bin/lua5.4 /usr/bin/lua

# Cài đặt LuaRocks cho Lua 5.4 và xóa các gói build không cần thiết để giảm dung lượng image
RUN apk add --no-cache --virtual .build-deps gcc libc-dev make unzip tar && \
  curl -L https://github.com/luarocks/luarocks/archive/refs/tags/v3.9.2.tar.gz | tar xz && \
  cd luarocks-3.9.2 && ./configure --with-lua-include=/usr/include/lua5.4 --with-lua-bin=/usr/bin && \
  make && make install && cd .. && rm -rf luarocks-3.9.2 && \
  apk del .build-deps

# Cài đặt LuaSocket từ source
RUN curl -L https://github.com/lunarmodules/luasocket/archive/refs/tags/v3.1.0.tar.gz | tar xz && \
  cd luasocket-3.1.0 && luarocks make rockspecs/luasocket-3.1.0-1.rockspec && \
  cd .. && rm -rf luasocket-3.1.0

# Cài đặt Redis Lua từ source
RUN curl -L https://github.com/nrk/redis-lua/archive/refs/tags/v2.0.4.tar.gz | tar xz && \
  cd redis-lua-2.0.4 && luarocks make rockspec/redis-lua-2.0.4-0.rockspec && \
  cd .. && rm -rf redis-lua-2.0.4

# Cập nhật PATH để LuaRocks có thể sử dụng
RUN echo "export PATH=$PATH:/usr/local/bin" >> /etc/profile

# Tạo thư mục cấu hình của HAProxy
RUN mkdir -p /usr/local/etc/haproxy/lua

# Sao chép cấu hình HAProxy và các file Lua vào container
# COPY ./haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY lua /usr/local/etc/haproxy/lua

# Mở cổng cho HAProxy
EXPOSE 80 443

# Lệnh giúp kiểm tra các công cụ và lịch sử
RUN echo "du -h" >> ~/.ash_history && \
  echo "apk info" >> ~/.ash_history && \
  echo "luarocks --version" >> ~/.ash_history && \
  echo "luarocks list" >> ~/.ash_history && \
  echo "haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg" >> ~/.ash_history

# Xác định tín hiệu dừng container
STOPSIGNAL SIGQUIT

# Lệnh khởi động HAProxy
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
