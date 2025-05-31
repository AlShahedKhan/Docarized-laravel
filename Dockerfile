# Use official PHP 8.3 FPM image
FROM php:8.3-fpm

# Arguments for creating a non-root user
ARG user
ARG uid

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Composer from its official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a non-root user with specified UID
RUN useradd -u ${uid} -ms /bin/bash -g www-data ${user}

# Set working directory
WORKDIR /var/www

# Copy files and set permissions
COPY --chown=${user}:www-data . /var/www

# Allow permission for the storage and bootstrap cache (optional)
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Switch to non-root user
USER ${user}

# Expose the PHP-FPM port
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"]
