# Complete Guide to Dockerize Laravel Applications (Reusable Documentation)

This guide clearly outlines the process for setting up a fully Dockerized Laravel application using Docker Compose, PHP-FPM, Nginx, and MySQL.

## Step 1: Preparation & Requirements

### Install Docker & Docker Compose

* Install Docker Desktop: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* Ensure Docker Compose is available.

## Step 2: Prepare Laravel Project

Generate a Laravel project:

```bash
composer create-project laravel/laravel my-laravel-project
```

## Step 3: Docker Configuration Files

Create these files in your project's root:

### Dockerfile

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
    unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -u $uid -ms /bin/bash -g www-data $user

WORKDIR /var/www

COPY --chown=$user:www-data . /var/www

EXPOSE 9000

CMD ["php-fpm"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build:
      args:
        user: laravel
        uid: 1000
      context: .
      dockerfile: Dockerfile
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

networks:
  laravel_network:
    driver: bridge

volumes:
  dbdata:
```

### nginx.conf

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

## Step 4: Running Docker

Execute:

```bash
docker-compose up -d --build
```

## Step 5: Laravel Setup Inside Docker

Run inside the container:

```bash
docker-compose exec app composer install
docker-compose exec app cp .env.example .env
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate
```

## Step 6: Update `.env` for Database

```dotenv
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

## Step 7: Access Laravel Application

Visit:

```
http://localhost:8080
```

## Troubleshooting

* Check status: `docker-compose ps`
* View logs: `docker-compose logs -f`
* Permission fix:

```bash
docker-compose exec app chown -R laravel:www-data /var/www
```

## Best Practices

* Clearly define Docker Compose services.
* Regularly update Docker images.
* Always sync `.env` settings with Docker setup.

Congratulations! You're ready to efficiently Dockerize any Laravel project.
