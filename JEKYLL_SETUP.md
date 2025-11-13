# Jekyll Setup Instructions

## 🎯 Tổng quan

Tài liệu NQDEV Containers đã được setup với Jekyll theme để tạo ra một website documentation chuyên nghiệp. Jekyll sẽ tự động build và deploy lên GitHub Pages khi có thay đổi.

## 📋 Cấu trúc Jekyll

```
docs/
├── _config.yml              # Jekyll configuration
├── _layouts/                 # Custom layouts
│   ├── default.html
│   └── guide.html
├── _includes/                # Reusable components
│   ├── head.html
│   ├── header.html
│   └── footer.html
├── assets/
│   └── css/
│       └── style.scss        # Custom styles
├── Gemfile                   # Ruby dependencies
├── index.md                  # Homepage
└── *.md                     # Documentation pages
```

## 🚀 Local Development

### Prerequisites

- Ruby 3.1+
- Bundler gem

### Setup

```bash
# Cài đặt Ruby dependencies
cd docs
bundle install

# Start development server
bundle exec jekyll serve --livereload

# Truy cập http://localhost:4000
```

### Development Workflow

1. **Edit content**: Modify `.md` files
2. **Add pages**: Create new `.md` files with front matter
3. **Customize styles**: Edit `assets/css/style.scss`
4. **Test locally**: Use `bundle exec jekyll serve`
5. **Deploy**: Push to GitHub (auto-deploy via Actions)

## 📝 Content Guidelines

### Front Matter

Tất cả markdown files cần có YAML front matter:

```yaml
---
layout: default
title: Page Title
nav_order: 1
---
```

### Navigation

Update `_config.yml` để thay đổi navigation:

```yaml
header_pages:
  - index.md
  - guides.md
  - examples.md
```

### Styling Classes

- `.note` - Info callouts
- `.warning` - Warning callouts
- `.highlight` - Highlighted content
- `.grid-container` - Grid layout
- `.code-example` - Code examples

## 🔧 Customization

### Colors

Sửa CSS variables trong `style.scss`:

```scss
:root {
  --nqdev-primary: #2563eb;
  --nqdev-secondary: #7c3aed;
  --nqdev-success: #059669;
}
```

### Layouts

Tạo layout mới trong `_layouts/`:

```html
---
layout: default
---

<article class="custom-layout">{{ content }}</article>
```

### Components

Tạo reusable components trong `_includes/`. Ví dụ, tạo service card component:

```html
<!-- _includes/service-card.html -->
<div class="service-card">
  <h3>{{ include.title }}</h3>
  <p>{{ include.description }}</p>
  {% if include.link %}
  <a href="{{ include.link | relative_url }}">Learn More →</a>
  {% endif %}
</div>
```

Sử dụng trong markdown:

```liquid
{% raw %}
{% include service-card.html
   title="NGINX"
   description="Web server with custom modules"
   link="/nginx-guide"
%}
{% endraw %}
```

Kết quả:

{% include service-card.html
   title="NGINX Example"
   description="Web server with custom modules and advanced features"
   link="/nginx-guide"
%}

## 🚀 Deployment

### GitHub Pages (Automatic)

1. Push changes to `main` branch
2. GitHub Actions sẽ tự động build và deploy
3. Website available tại: `https://nqdev-group.github.io/containers`

### Manual Build

```bash
# Build for production
bundle exec jekyll build --baseurl "/containers"

# Output trong _site/ folder
```

## 📊 Features Included

### ✅ Responsive Design

- Mobile-friendly navigation
- Grid layouts
- Responsive tables

### ✅ Syntax Highlighting

- Code blocks với highlighting
- Copy-to-clipboard functionality
- Multiple language support

### ✅ Search & Navigation

- Clear page structure
- Breadcrumb navigation
- Quick links

### ✅ SEO Optimized

- Meta tags via jekyll-seo-tag
- Structured data
- Social media previews

### ✅ Performance

- Minified CSS/JS
- Optimized images
- Fast loading

## 🔍 Troubleshooting

### Common Issues

1. **Bundle install fails**

   ```bash
   gem install bundler
   bundle update
   ```

2. **Jekyll serve fails**

   ```bash
   bundle exec jekyll clean
   bundle exec jekyll serve
   ```

3. **CSS không load**

   - Check `_config.yml` baseurl
   - Verify `assets/css/style.scss`

4. **GitHub Pages build fails**
   - Check GitHub Actions logs
   - Verify Gemfile và \_config.yml

### Performance Tips

- Optimize images trước khi commit
- Minify CSS trong production
- Use CDN cho external libraries
- Enable compression trên server

## 📚 Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages](https://pages.github.com/)
- [Liquid Template Language](https://shopify.github.io/liquid/)
- [Kramdown Syntax](https://kramdown.gettalong.org/syntax.html)

---

**NQDEV Team** - Platform Engineering  
📧 quynh@nhquydev.net | 🌐 [nhquydev.net](https://nhquydev.net)
