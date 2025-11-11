# WordPress Container

Container WordPress được tùy chỉnh dựa trên Bitnami WordPress image với các cấu hình tối ưu cho môi trường production.

## Tổng quan

WordPress container này cung cấp:

- WordPress 6.8.3 với PHP 8.4.13
- Apache 2.4.65 web server
- Hỗ trợ cả MariaDB và MySQL làm database
- SSL/TLS support
- Pre-configured cho development và production

## Cấu trúc thư mục

```
wordpress/
├── README.md                    # Tài liệu hướng dẫn
├── docker-compose.yml           # Cấu hình với MariaDB
├── docker-compose-mysql.yml     # Cấu hình với MySQL
└── 6/
    └── debian-12/
        ├── Dockerfile           # WordPress 6 trên Debian 12
        ├── prebuildfs/          # Pre-build filesystem
        └── rootfs/              # Root filesystem customizations
```

## Tính năng

### WordPress Features

- ✅ WordPress 6.8.3 (Latest stable)
- ✅ PHP 8.4.13 với các extensions cần thiết
- ✅ Apache mod_php configuration
- ✅ WP-CLI command line tool
- ✅ Multisite support
- ✅ Custom themes và plugins support

### Database Support

- ✅ MariaDB (recommended)
- ✅ MySQL 8.0+
- ✅ Persistent volume storage
- ✅ Automatic database initialization

### Security & Performance

- ✅ SSL/TLS ready (port 8443)
- ✅ Non-root user execution
- ✅ Optimized PHP configuration
- ✅ Security headers configured

## Hướng dẫn sử dụng

### 1. Sử dụng với MariaDB (Khuyên dùng)

```bash
# Clone repository
git clone <repository-url>
cd nqdev-containers/nqdev/wordpress

# Khởi chạy với MariaDB
docker-compose up -d

# Hoặc build custom image
docker-compose up --build -d
```

### 2. Sử dụng với MySQL

```bash
# Sử dụng MySQL thay vì MariaDB
docker-compose -f docker-compose-mysql.yml up -d
```

### 3. Build custom image

```bash
# Build WordPress image từ Dockerfile
cd 6/debian-12
docker build -t nqdev/wordpress:6-debian-12 .

# Hoặc sử dụng docker-compose
docker-compose build wordpress
```

## Cấu hình

### Environment Variables

#### WordPress Configuration

| Variable               | Default            | Description              |
| ---------------------- | ------------------ | ------------------------ |
| `WORDPRESS_USERNAME`   | `user`             | WordPress admin username |
| `WORDPRESS_PASSWORD`   | `bitnami123`       | WordPress admin password |
| `WORDPRESS_EMAIL`      | `user@example.com` | WordPress admin email    |
| `WORDPRESS_FIRST_NAME` | `FirstName`        | Admin first name         |
| `WORDPRESS_LAST_NAME`  | `LastName`         | Admin last name          |
| `WORDPRESS_BLOG_NAME`  | `User's Blog!`     | Blog title               |

#### Database Configuration

| Variable                         | Default             | Description       |
| -------------------------------- | ------------------- | ----------------- |
| `WORDPRESS_DATABASE_HOST`        | `mariadb`           | Database host     |
| `WORDPRESS_DATABASE_PORT_NUMBER` | `3306`              | Database port     |
| `WORDPRESS_DATABASE_USER`        | `bn_wordpress`      | Database username |
| `WORDPRESS_DATABASE_PASSWORD`    | ``                  | Database password |
| `WORDPRESS_DATABASE_NAME`        | `bitnami_wordpress` | Database name     |

#### Security Settings

| Variable                   | Default | Description                      |
| -------------------------- | ------- | -------------------------------- |
| `ALLOW_EMPTY_PASSWORD`     | `yes`   | Allow empty passwords (dev only) |
| `WORDPRESS_ENABLE_HTTPS`   | `no`    | Enable HTTPS                     |
| `WORDPRESS_SKIP_BOOTSTRAP` | `no`    | Skip WordPress setup             |

### Ports

- **8080**: HTTP port
- **8443**: HTTPS port

### Volumes

- `wordpress_data`: WordPress files và uploads
- `mariadb_data`/`mysql_data`: Database data

## Production Setup

### 1. Cấu hình SSL/HTTPS

```yaml
services:
  wordpress:
    environment:
      - WORDPRESS_ENABLE_HTTPS=yes
      - WORDPRESS_EXTERNAL_HTTP_PORT_NUMBER=80
      - WORDPRESS_EXTERNAL_HTTPS_PORT_NUMBER=443
    volumes:
      - "./certs:/opt/bitnami/apache/certs"
```

### 2. Sử dụng External Database

```yaml
services:
  wordpress:
    environment:
      - WORDPRESS_DATABASE_HOST=your-db-host.com
      - WORDPRESS_DATABASE_PORT_NUMBER=3306
      - WORDPRESS_DATABASE_USER=wordpress_user
      - WORDPRESS_DATABASE_PASSWORD=secure_password
      - WORDPRESS_DATABASE_NAME=wordpress_db
      - ALLOW_EMPTY_PASSWORD=no
```

### 3. Persistent Storage

```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/wordpress-data
```

## WP-CLI Usage

```bash
# Truy cập container
docker-compose exec wordpress bash

# Sử dụng WP-CLI
wp --info
wp plugin list
wp theme list
wp user list

# Install plugin
wp plugin install woocommerce --activate

# Update WordPress
wp core update
```

## Backup và Restore

### Backup

```bash
# Backup WordPress files
docker run --rm -v wordpress_wordpress_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/wordpress-files-$(date +%Y%m%d).tar.gz -C /data .

# Backup database
docker-compose exec mariadb mysqldump -u bn_wordpress bitnami_wordpress > wordpress-db-$(date +%Y%m%d).sql
```

### Restore

```bash
# Restore WordPress files
docker run --rm -v wordpress_wordpress_data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/wordpress-files-20241112.tar.gz -C /data

# Restore database
docker-compose exec -T mariadb mysql -u bn_wordpress bitnami_wordpress < wordpress-db-20241112.sql
```

## Monitoring và Logs

```bash
# Xem logs
docker-compose logs -f wordpress
docker-compose logs -f mariadb

# Monitor resource usage
docker stats wordpress_wordpress_1 wordpress_mariadb_1

# Health check
curl -I http://localhost/wp-admin/install.php
```

## Troubleshooting

### Common Issues

1. **Permission Issues**

   ```bash
   docker-compose exec wordpress chown -R bitnami:bitnami /bitnami/wordpress
   ```

2. **Database Connection Error**

   ```bash
   # Check database status
   docker-compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"

   # Reset database password
   docker-compose exec mariadb mysql -u root -p -e "ALTER USER 'bn_wordpress'@'%' IDENTIFIED BY 'new_password';"
   ```

3. **Memory Issues**
   ```bash
   # Increase PHP memory limit
   echo "memory_limit = 512M" >> /opt/bitnami/php/etc/php.ini
   ```

### Debug Mode

```yaml
services:
  wordpress:
    environment:
      - WORDPRESS_DEBUG=yes
      - WORDPRESS_DEBUG_LOG=yes
```

## Performance Tuning

### PHP Configuration

```ini
# /opt/bitnami/php/etc/php.ini
memory_limit = 512M
max_execution_time = 300
max_input_vars = 3000
upload_max_filesize = 64M
post_max_size = 64M
```

### Apache Configuration

```apache
# Trong .htaccess hoặc virtual host
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
</IfModule>
```

## Security Best Practices

1. **Sử dụng strong passwords**
2. **Disable file editing trong WordPress admin**
3. **Regular updates**
4. **Sử dụng SSL certificates**
5. **Backup thường xuyên**
6. **Monitor logs for suspicious activities**

## Contributing

Khi contribute vào project này:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Tạo Pull Request

## Support

- **Documentation**: [Bitnami WordPress Documentation](https://docs.bitnami.com/containers/apps/wordpress/)
- **Issues**: Tạo issue trong repository
- **Community**: WordPress Support Forums

## License

Project này sử dụng Apache 2.0 License. Xem file [LICENSE](../../LICENSE) để biết thêm chi tiết.

---

**Lưu ý**: Cấu hình mặc định phù hợp cho development environment. Đối với production, hãy đảm bảo:

- Tắt `ALLOW_EMPTY_PASSWORD`
- Sử dụng strong passwords
- Enable HTTPS
- Cấu hình proper backup strategy
- Monitor resource usage và performance
