# Sử dụng image syslog-ng chính thức
FROM balabit/syslog-ng:latest

# Cài đặt logrotate và cron
RUN apt-get update && apt-get install -y logrotate cron

# Sao chép cấu hình logrotate vào container
COPY syslog-ng-logrotate /etc/logrotate.d/syslog-ng

# Tạo cron job để chạy logrotate mỗi ngày
RUN echo "0 0 * * * /usr/sbin/logrotate /etc/logrotate.d/syslog-ng" > /etc/cron.d/logrotate \
  && chmod 0644 /etc/cron.d/logrotate \
  && crontab /etc/cron.d/logrotate

# Khởi chạy syslog-ng và cron cùng lúc
CMD service cron start && syslog-ng -F
