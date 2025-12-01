## Các bước sử dụng

1. Tạo Dockerfile: Lưu nội dung Dockerfile vào một file tên `Dockerfile`.
2. Tạo entrypoint.sh: Lưu script `entrypoint.sh` vào cùng thư mục với Dockerfile và Docker Compose.
3. Tạo Docker Compose file: Lưu nội dung của Docker Compose vào một file tên `docker-compose.yml`.
4. Xây dựng và chạy container:
   - Chạy lệnh `docker-compose up --build` để xây dựng và chạy container.
   - Docker Compose sẽ tự động tải image, cấu hình GitHub Actions runner, và bắt đầu chạy.
5. Cấu hình GitHub Actions: Sau khi container đã chạy, bạn cần thêm runner vào repository của bạn bằng cách sử dụng token (`RUNNER_TOKEN`) mà bạn đã tạo từ GitHub.

## Thêm vào Workflow GitHub Actions

Cuối cùng, bạn chỉ cần cấu hình các job trong file workflow của GitHub:

```yaml
jobs:
  my-job:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Run a script
        run: echo "Hello from self-hosted runner!"
```

### Lưu ý:

- Thay thế `your-repo` và `your-generated-token` bằng URL của repository của bạn và token tự tạo từ GitHub.
- Đảm bảo Docker và Docker Compose đã được cài đặt trên hệ thống của bạn.
