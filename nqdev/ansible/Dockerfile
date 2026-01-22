# Dockerfile for Ansible Development Environment
# docker run -d --name test-ssh -p 2222:22 my-ubuntu-ssh
# # Đợi vài giây cho container khởi động
# ssh admin@localhost -p 2222
# # Password: password123

# Sử dụng image ubuntu:latest làm base image
FROM ubuntu:25.10

# Thêm metadata labels
LABEL org.opencontainers.image.title="Ansible Development Environment" \
  org.opencontainers.image.version="17.5" \
  org.opencontainers.image.description="Ansible development environment with necessary tools" \
  org.opencontainers.image.authors="QuyIT Platform <quynh@nhquydev.net>" \
  org.opencontainers.image.licenses="MIT"

# Khai báo các lệnh môi trường hoặc thiết lập các biến môi trường (tuỳ chọn)
ENV TIMEZONE=Asia/Ho_Chi_Minh

# Cài đặt các gói cần thiết
RUN apt-get update && \
  apt-get install --yes --no-install-recommends \
  tzdata \
  dos2unix \
  htop \
  openssh-server \
  sudo \
  passwd \
  fail2ban \
  software-properties-common && \
  ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone && \
  apt-add-repository --yes --update ppa:ansible/ansible && \
  apt install ansible --yes && \
  mkdir -p /opt/ansible && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Thiết lập SSH
RUN mkdir -p /var/run/sshd \
  && useradd -m -d /home/admin -s /bin/bash admin \
  && echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Tạo các thư mục cần thiết
RUN mkdir -p /nqdev/ansible/scripts && \
  mkdir -p /nqdev/ansible/sources

# Sao chép các file khởi tạo và script vào container
COPY jail.local /etc/fail2ban/jail.local
COPY sources/ /nqdev/ansible/sources/
COPY scripts/ /nqdev/ansible/scripts/

RUN chmod +x /nqdev/ansible/scripts/*.sh && \
  dos2unix /nqdev/ansible/scripts/*.sh

# Đặt thư mục làm việc mặc định trong container
WORKDIR /opt/ansible

# Mở cổng SSH (22) hoặc tuỳ chỉnh khác (ví dụ 2222, đồng bộ EXPOSE phía sau)
EXPOSE 22

# Xác định tín hiệu dừng container
STOPSIGNAL SIGQUIT

# Start SSHD mặc định và giữ container chạy
# CMD ["/usr/sbin/sshd", "-D"]
# Nếu muốn khởi động script trước rồi mới khởi động sshd, cấu hình ENTRYPOINT hoặc tail -f như bên dưới và chạy sshd trong background
ENTRYPOINT ["/nqdev/ansible/scripts/00-start-sshd.sh"]

# Hoặc nếu muốn container vừa khởi động sshd vừa chạy tail:
# CMD service ssh start && tail -f /dev/null

