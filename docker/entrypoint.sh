#!/usr/bin/env bash
set -e

cd /var/www/html

# Ensure writable storage and cache directories
mkdir -p \
    storage/framework/sessions \
    storage/framework/views \
    storage/framework/cache \
    storage/logs \
    storage/app/public \
    bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Wait for MySQL when DB_CONNECTION is mysql/mariadb
if [ "${DB_CONNECTION:-mysql}" = "mysql" ] || [ "${DB_CONNECTION:-mysql}" = "mariadb" ]; then
    DB_HOST_VAL="${DB_HOST:-db}"
    DB_PORT_VAL="${DB_PORT:-3306}"
    echo "Waiting for database at ${DB_HOST_VAL}:${DB_PORT_VAL}..."
    TRIES=0
    MAX_TRIES=30
    until nc -z "${DB_HOST_VAL}" "${DB_PORT_VAL}" >/dev/null 2>&1; do
        TRIES=$((TRIES + 1))
        if [ "$TRIES" -ge "$MAX_TRIES" ]; then
            echo "Database not reachable after ${MAX_TRIES} attempts. Exiting."
            exit 1
        fi
        sleep 2
    done
    echo "Database is reachable."
fi

# Create storage symlink if missing
if [ ! -L public/storage ]; then
    php artisan storage:link --no-interaction || true
fi

# Run migrations if enabled
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    echo "Running database migrations..."
    php artisan migrate --force --no-interaction
fi

# Run seeders if explicitly enabled
if [ "${RUN_SEEDERS:-false}" = "true" ]; then
    echo "Running database seeders..."
    php artisan db:seed --force --no-interaction
fi

# Cache configuration, routes, and views in production
if [ "${APP_ENV:-production}" = "production" ]; then
    php artisan config:cache --no-interaction
    php artisan route:cache --no-interaction
    php artisan view:cache --no-interaction
fi

exec "$@"
