# 🐳 Hướng dẫn chạy Ansible bằng Docker

Dưới đây là cách bạn có thể chạy Ansible bằng Docker Compose, cực kỳ gọn gàng và tiện để tái sử dụng trong các project tự động hóa.

## 📦 Cấu trúc thư mục

```bash
ansible-docker/
├── docker-compose.yml
├── Dockerfile
├── inventory.ini
└── playbook.yml
```

## 🐳 1. Dockerfile

```Dockerfile
FROM python:3.10-slim

RUN pip install --no-cache-dir ansible

WORKDIR /ansible

```

### 🛠 2. docker-compose.yml

```yaml
version: "3.8"

services:
  ansible:
    build: .
    container_name: ansible
    volumes:
      - .:/ansible
      - ~/.ssh:/root/.ssh:ro
    working_dir: /ansible
    stdin_open: true
    tty: true
```

### 📦 Gợi ý thêm:

Bạn có thể tạo sẵn `Makefile` như sau để rút gọn lệnh:

```Makefile
up:
	docker-compose build

bash:
	docker-compose run ansible bash

ping:
	docker-compose run ansible ansible -i inventory.ini all -m ping

run:
	docker-compose run ansible ansible-playbook -i inventory.ini playbook.yml

```
