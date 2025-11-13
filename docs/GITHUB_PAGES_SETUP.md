# GitHub Pages Setup Guide

## 🛠️ Khắc phục lỗi GitHub Pages

Nếu bạn gặp lỗi `Get Pages site failed`, hãy làm theo các bước sau:

### 1. Enable GitHub Pages

1. Vào repository trên GitHub
2. Click **Settings** tab
3. Scroll xuống **Pages** section (bên trái sidebar)
4. Trong **Source**, chọn **GitHub Actions**
5. Click **Save**

### 2. Kiểm tra Permissions

Đảm bảo repository có permissions cần thiết:

1. Vào **Settings** → **Actions** → **General**
2. Trong **Workflow permissions**, chọn:
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**
3. Click **Save**

### 3. Alternative: Sử dụng gh-pages Branch

Nếu vẫn gặp lỗi, sử dụng workflow đơn giản hơn:

```bash
# Sử dụng docs-simple.yml thay vì docs.yml
mv .github/workflows/docs.yml .github/workflows/docs.yml.backup
mv .github/workflows/docs-simple.yml .github/workflows/docs.yml
```

### 4. Manual Setup (nếu cần)

```bash
# 1. Build locally
cd docs
bundle install
bundle exec jekyll build

# 2. Push _site content to gh-pages branch
git checkout -b gh-pages
cp -r _site/* .
git add .
git commit -m "Deploy Jekyll site"
git push origin gh-pages

# 3. Configure Pages source
# GitHub Settings → Pages → Source: Deploy from branch → gh-pages
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Pages not enabled

```
Error: Get Pages site failed. Please verify that the repository has Pages enabled
```

**Solution**: Enable Pages trong repository settings

#### 2. Permission denied

```
Error: HttpError: Forbidden
```

**Solution**: Check workflow permissions trong Actions settings

#### 3. Build fails

```
Error: The process 'bundle' with arguments 'exec jekyll build' failed
```

**Solution**: Check Ruby version và dependencies trong Gemfile

### 4. Wrong base URL

```
Assets not loading correctly
```

**Solution**: Update `_config.yml`:

```yaml
url: "https://nqdev-group.github.io"
baseurl: "/containers"
```

## ✅ Verification

Sau khi setup thành công:

1. **Build Action**: Check trong **Actions** tab
2. **Deployment**: Check trong **Deployments** (repository main page)
3. **Live Site**: Visit `https://nqdev-group.github.io/containers`

## 🚀 Development Workflow

### Local Development

```bash
cd docs
bundle install
bundle exec jekyll serve --livereload
# Visit: http://localhost:4000/containers
```

### Deploy to Production

```bash
git add .
git commit -m "Update documentation"
git push origin main  # Triggers auto-deployment
```

## 📋 Final Checklist

- [ ] Repository có public visibility (hoặc GitHub Pro/Team)
- [ ] Pages enabled trong Settings
- [ ] Workflow permissions configured
- [ ] `_config.yml` có đúng `url` và `baseurl`
- [ ] Action workflow chạy thành công
- [ ] Website accessible tại GitHub Pages URL

## 🆘 Still Having Issues?

1. **Check Action Logs**: Xem detailed error trong Actions tab
2. **Verify Settings**: Double-check Pages và Actions settings
3. **Try Simple Workflow**: Sử dụng `docs-simple.yml` approach
4. **Contact Support**: Create issue trong repository

---

**NQDEV Team** - Platform Engineering  
📧 quynh@nhquydev.net
