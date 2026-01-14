# virtualenv

- `pip install virtualenv`
- `virtualenv env -p E:\sys\services\Python\Python311\python.exe`
- `.\env\Scripts\activate`
- `deactivate`
- `python -m pip freeze > requirements.txt` -> backup package
- `pip install -r requirements.txt` -> restorage package
- `python manage.py makemigrations`
- `python manage.py migrate` -> tạo database, nếu chưa có sẵn database
- `python manage.py runserver 0.0.0.0:8000` -> start for all ip

# 🐍 Chi tiết về Ansible & Python

✅ Ansible là một ứng dụng được viết bằng ngôn ngữ Python.

| Thành phần     | Mô tả                                                            |
| -------------- | ---------------------------------------------------------------- |
| Ngôn ngữ chính | Python                                                           |
| Thư viện dùng  | Sử dụng nhiều thư viện chuẩn Python như paramiko, jinja2, pyyaml |
| Cách hoạt động | Ansible dùng Python để chạy các module qua SSH trên máy từ xa    |
| Agentless      | Không cần cài Ansible trên máy đích, chỉ cần Python và SSH là đủ |

## 🔍 1. Mã nguồn Ansible ở đâu?

Bạn có thể xem trực tiếp tại GitHub:

🔗 Repo chính thức: https://github.com/ansible/ansible

## 🔧 Trên máy từ xa cần gì?

Ansible cần:

✅ Python 2.7 hoặc Python 3.x đã được cài sẵn
✅ SSH kết nối được từ máy chạy Ansible (control node)

> 📌 Lưu ý: Nếu máy đích là hệ điều hành đặc biệt (VD: Alpine, thiết bị IoT...) không có Python thì bạn cần **cài Python trước hoặc dùng Ansible bằng raw module** (không cần Python).

## 🛠 Một số file chính trong source Ansible:

| File / Thư mục      | Vai trò                       |
| ------------------- | ----------------------------- |
| `ansible/`          | Source chính của project      |
| `ansible/modules/`  | Nơi chứa các module Python    |
| `ansible/cli/`      | Xử lý lệnh CLI (command line) |
| `ansible/playbook/` | Logic xử lý playbook          |

## 📦 Cài đặt Ansible bằng pip (Python Package)

Nếu bạn đã có Python:

```bash
pip install ansible
```

> 🎯 Có thể tạo virtual environment để quản lý dễ hơn.

# 🎯 Dùng Ansible SSH vào một server CentOS và cài đặt Docker.

## 📋 Bước 1: Kiểm tra SSH key và kết nối đến server CentOS

Đảm bảo bạn đã SSH được thủ công:

```bash
ssh root@192.168.1.100
```

Nếu chưa có SSH key:

```bash
ssh-keygen
ssh-copy-id root@192.168.1.100
```

## 📁 Bước 2: Tạo file inventory

Tạo file `inventory.ini`:

```ini
[centos]
192.168.1.100 ansible_user=root ansible_python_interpreter=/usr/bin/python3
```

📌 Ghi chú:

- Dùng ansible_user=root hoặc user khác nếu không dùng root
- ansible_python_interpreter=/usr/bin/python3: rất quan trọng, vì CentOS thường mặc định dùng Python 2
