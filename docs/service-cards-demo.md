---
layout: default
title: Service Cards Demo
---

# Service Cards Demo

This page demonstrates the `service-card.html` component in action.

## NQDEV Container Services

<div class="grid-container">
{% include service-card.html 
   icon="🌐"
   title="NGINX Container"
   description="High-performance web server with custom modules including rate limiting, GeoIP, and SSL/TLS optimization."
   image="nqdev/nginx:1.27.2-alpine-vhs-custom-1.5.1"
   ports="32768, 18080"
   features="Custom modules, GeoIP support, Rate limiting, SSL/TLS optimization, Performance monitoring"
   link="/nginx-guide"
%}

{% include service-card.html
   icon="⚖️"
   title="HAProxy Container"
   description="Load balancer with Lua scripting and Redis rate limiting for high-availability traffic management."
   image="nqdev/haproxy-alpine-custom:3.1.5"
   ports="18080, 17001"
   features="Lua scripting, Redis integration, SSL termination, Health checks, Stats dashboard"
   link="/haproxy-guide"
%}

{% include service-card.html
   icon="🗄️"
   title="PostgreSQL + pgAgent"
   description="Database server with pgAgent job scheduler and HTTP extension for automated tasks."
   image="postgres:17.5-custom"
   ports="5432"
   features="Job scheduling, HTTP extension, Automated backups, Performance optimization"
   link="/postgresql-guide"
%}

{% include service-card.html
   icon="📱"
   title="WordPress Container"
   description="Content management system with PHP 8.4, Apache web server, and WP-CLI tools."
   image="WordPress 6.8.3 on Debian 12"
   ports="8080, 8443"
   features="PHP 8.4, Apache server, SSL ready, WP-CLI, Plugin support"
   link="/wordpress-guide"
%}

{% include service-card.html
   icon="🐰"
   title="RabbitMQ Container"
   description="Message broker with clustering support and management UI for microservices communication."
   image="bitnamilegacy/rabbitmq:4.1"
   ports="5672, 15672"
   features="Clustering, Management UI, SSL support, High availability"
   link="/rabbitmq-guide"
%}

</div>

## Simple Service Card

{% include service-card.html
   title="Example Service"
   description="This is a simple service card without all the optional parameters."
%}
