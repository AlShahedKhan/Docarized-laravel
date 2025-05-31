# 🚀 Dockerized Laravel Application with MySQL, Nginx, Redis, and Vite

This guide provides a fully Dockerized setup for Laravel using **PHP-FPM**, **MySQL**, **Nginx**, **Redis**, and **Vite**, complete with configuration files, environment variables, and best practices.

---

## 🪰 Prerequisites

* [Docker Desktop](https://www.docker.com/products/docker-desktop)
* Docker Compose (comes with Docker Desktop)
* Node.js & npm (for Vite)
* Composer
* Git (optional)

---

## 📁 Project Structure

```plaintext
my-laravel-project/
├── Dockerfile
├── docker-compose.yml
├── docker-compose/
│   └── nginx/
│       └── default.conf
├── .env
└── Laravel application files...
```

---

## 📆 Installation & Setup

### 1. Create Laravel Project

```bash
composer create-project laravel/laravel my-laravel-project
cd my-laravel-project
```

### 2. Dockerfile

```Dockerfile
FROM php:8.2-fpm

ARG user
ARG uid

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    npm nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -u $uid -ms /bin/bash -g www-data $user

WORKDIR /var/www

COPY --chown=$user:www-data . /var/www

EXPOSE 9000

CMD ["php-fpm"]
```

### 3. docker-compose.yml

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
      - ./docker-compose/nginx/default.conf:/etc/nginx/conf.d/default.conf
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

### 4. Nginx Config (default.conf)

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

## 🚀 Getting Started

### Step 1: Build & Start Containers

```bash
docker-compose up -d --build
```

### Step 2: Laravel Setup

```bash
docker-compose exec app composer install
docker-compose exec app cp .env.example .env
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate
docker-compose exec app php artisan storage:link
```

### Step 3: Update `.env`

```dotenv
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
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

VITE_APP_NAME="${APP_NAME}"
```

### Step 4: Install Redis Client

```bash
docker-compose exec app composer require predis/predis
```

### Step 5: Build Vite Assets

```bash
npm install
npm run dev   # or npm run build for production
```

---

## 🧰 Testing Redis

```bash
docker-compose exec app php artisan tinker

>>> Cache::put('test', 'redis is working', 10);
>>> Cache::get('test');
=> "redis is working"
```

---

## 🛠️ Common Commands

| Command                        | Description                  |
| ------------------------------ | ---------------------------- |
| `docker-compose ps`            | Check containers             |
| `docker-compose logs -f`       | Follow logs                  |
| `docker-compose exec app bash` | Shell into Laravel container |
| `php artisan config:cache`     | Cache config                 |
| `docker-compose down -v`       | Remove volumes & containers  |

---

## 📅 What's Included

* Laravel 11+
* PHP 8.2 (FPM)
* MySQL 8.0
* Redis
* Nginx
* Vite frontend setup
* Docker Compose 3.8

---

## 💪 Final Notes

You now have a complete, production-ready **Docker environment for Laravel** that supports Redis, Vite, MySQL, and Nginx.

Let me know if you want this as a PDF, deploy-ready GitHub template, or with GitHub Actions for CI/CD!

---

## 📄 License

[MIT](./LICENSE)
