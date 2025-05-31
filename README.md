Absolutely! Here's your **updated complete guide** with **Redis setup** fully integrated, while keeping everything clean, reusable, and production-friendly.

---

# 🚀 Complete Guide to Dockerize Laravel Applications (with Redis Support)

This guide outlines the process to set up a **fully Dockerized Laravel application** using **Docker Compose**, **PHP-FPM**, **Nginx**, **MySQL**, and **Redis**.

---

## Step 1: Preparation & Requirements

### ✅ Install Docker & Docker Compose

* [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
* Confirm Docker Compose is included by running:

  ```bash
  docker-compose --version
  ```

---

## Step 2: Prepare Laravel Project

Create a new Laravel project:

```bash
composer create-project laravel/laravel my-laravel-project
cd my-laravel-project
```

---

## Step 3: Docker Configuration Files

Create the following files in your project root.

---

### 📄 Dockerfile

```Dockerfile
FROM php:8.3-fpm

ARG user
ARG uid

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    redis \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -u $uid -ms /bin/bash -g www-data $user

WORKDIR /var/www

COPY --chown=$user:www-data . /var/www

EXPOSE 9000

CMD ["php-fpm"]
```

---

### 📄 docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        user: laravel
        uid: 1000
    container_name: laravel_app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./:/var/www
    networks:
      - laravel_network

  webserver:
    image: nginx:alpine
    container_name: laravel_webserver
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./:/var/www
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - laravel_network

  db:
    image: mysql:8.0
    container_name: laravel_db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: laravel
      MYSQL_USER: laravel
      MYSQL_PASSWORD: secret
    ports:
      - "3306:3306"
    volumes:
      - dbdata:/var/lib/mysql
    networks:
      - laravel_network

  redis:
    image: redis:alpine
    container_name: laravel_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    networks:
      - laravel_network

networks:
  laravel_network:
    driver: bridge

volumes:
  dbdata:
```

---

### 📄 nginx.conf

```nginx
server {
    listen 80;
    index index.php index.html;
    root /var/www/public;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

---

## Step 4: Start Docker Services

```bash
docker-compose up -d --build
```

---

## Step 5: Laravel Setup Inside Docker

```bash
docker-compose exec app composer install
docker-compose exec app cp .env.example .env
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate
```

---

## Step 6: Update `.env` for MySQL and Redis

```dotenv
APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:...
APP_DEBUG=true
APP_URL=http://localhost:8080

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_CLIENT=predis
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
```

> 🔸 Use `REDIS_CLIENT=phpredis` only if you've installed the `phpredis` PHP extension in the Dockerfile.
> 🔸 Otherwise, stick to `REDIS_CLIENT=predis` and install `predis/predis`.

---

## Step 7: Install Redis Client for Laravel

If you're using **Predis**:

```bash
docker-compose exec app composer require predis/predis
```

---

## Step 8: Verify Redis Works

```bash
docker-compose exec app php artisan tinker

>>> Cache::put('hello', 'world', 10);
>>> Cache::get('hello');
=> "world"
```

---

## Step 9: Access Laravel App

Visit:

```
http://localhost:8080
```

---

## 🛠 Troubleshooting Tips

| Command                                    | Use                             |
| ------------------------------------------ | ------------------------------- |
| `docker-compose ps`                        | Check container status          |
| `docker-compose logs -f`                   | View logs                       |
| `docker-compose exec app bash`             | Access Laravel container        |
| `php artisan config:clear && config:cache` | Refresh Laravel config cache    |
| `composer dump-autoload`                   | Autoload fixes                  |
| `docker-compose down -v`                   | Reset everything (with volumes) |

---

## ✅ Best Practices

* Keep `.env` in sync with Docker services.
* Use `predis` unless you need native `phpredis` for performance.
* Define container `user:uid` to avoid file permission issues.
* Keep Redis for: caching, sessions, queues (even broadcasting).
* Use `Horizon` if managing queues via Redis for production apps.

---

## 🎉 You're Done!

You now have a **fully Dockerized Laravel environment with MySQL, Nginx, PHP-FPM, and Redis** — ready for modern development and scaling.

Let me know if you want a printable PDF version or GitHub repo template of this guide!
