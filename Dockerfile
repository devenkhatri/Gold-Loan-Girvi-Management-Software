# syntax=docker/dockerfile:1

# -----------------------------------------------------------------------------
# Stage 1: Build frontend assets with Node + Vite
# -----------------------------------------------------------------------------
FROM node:20-alpine AS assets

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY resources ./resources
COPY public ./public
COPY vite.config.js tailwind.config.js postcss.config.js ./

RUN npm run build

# -----------------------------------------------------------------------------
# Stage 2: Install PHP dependencies with Composer (using PHP 8.4 to match lockfile & runtime)
# -----------------------------------------------------------------------------
FROM php:8.4-cli-alpine AS vendor

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN apk add --no-cache unzip

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts \
    --ignore-platform-req=ext-gd \
    --ignore-platform-req=ext-zip

# -----------------------------------------------------------------------------
# Stage 3: PHP-FPM application runtime
# -----------------------------------------------------------------------------
FROM php:8.4-fpm-alpine AS app

# Install system utilities and PHP extensions required by Laravel, MySQL, DomPDF, and Maatwebsite Excel
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN apk add --no-cache bash netcat-openbsd \
    && install-php-extensions \
        pdo_mysql \
        gd \
        zip \
        intl \
        bcmath \
        opcache \
        pcntl \
        mbstring \
        xml

WORKDIR /var/www/html

# Copy application source
COPY . .

# Copy built vendor and frontend assets from previous stages
COPY --from=vendor /app/vendor ./vendor
COPY --from=assets /app/public/build ./public/build

# Copy PHP configuration and entrypoint
COPY docker/php/php.ini /usr/local/etc/php/conf.d/99-app.ini
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Ensure writable directories for www-data and discover Laravel packages
RUN mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache storage/logs storage/app/public bootstrap/cache \
    && php artisan package:discover --ansi --no-interaction \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]

# -----------------------------------------------------------------------------
# Stage 4: Nginx web server runtime
# -----------------------------------------------------------------------------
FROM nginx:1.27-alpine AS web

WORKDIR /var/www/html

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=app /var/www/html/public ./public

EXPOSE 80
