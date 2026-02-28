# Sử dụng image Ubuntu làm base image
FROM ubuntu:20.04

# Cập nhật và cài đặt các dependencies cần thiết
RUN apt-get update && apt-get install -y \
  wget \
  ca-certificates \
  fonts-liberation \
  libappindicator3-1 \
  libasound2 \
  libnss3 \
  libxss1 \
  xdg-utils \
  chromium-browser \
  && apt-get clean

# Cấu hình môi trường để Chromium có thể chạy
ENV CHROME_BIN=/usr/bin/chromium-browser

# Thiết lập command mặc định khi container chạy
CMD ["chromium-browser", "--no-sandbox"]