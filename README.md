# Gold Loan & Girvi Management Software (WeBotApp)

A compact, modern, lightweight **Gold Loan / Girvi Management Software** built with **Laravel 11**, **MySQL**, **Livewire**, and **Tailwind CSS** for Indian jewellery and gold loan businesses.

## Features

- **Dashboard:** Active loans, outstanding principal, total interest collected, customer count, loans due today, overdue alerts, vault collateral summary, and recent transactions.
- **Customer Management:** Add, edit, archive, and search customers with PAN/Aadhaar/ID proof KYC details, customer-wise loan history, and outstanding balance tracking.
- **Gold Pledge Management:** Track jewellery description, category, gross/stone/net gold weight, purity (`18K`, `20K`, `22K`, `24K`), market gold rate, valuation, packet number, locker reference, and printable vault tags.
- **Loan Management:** Automatic loan numbering (`LN-YYYY-XXXX`), multi-item collateral pledging, LTV calculation, and printable loan agreements/pledge receipts.
- **Interest Calculation:** Supports **Monthly**, **Daily**, **Annual**, **Flat**, and **Reducing Balance** interest methods with live accrued interest breakdown.
- **Payment Management:** Collect interest, principal, partial payments, and full settlements via **Cash**, **UPI**, **Bank Transfer**, or **Cheque** with immutable printable receipts.
- **Loan Renewals & Gold Release:** Extend maturity dates, record renewal interest, release settled collateral with handover certificates, and enforce admin override protection for unsettled loans.
- **Reports & Exports:** Daily/monthly collection reports, active/overdue/closed loan reports, vault portfolio summary, customer ledger, CSV export, and print-ready views.
- **Users & Settings:** Admin/staff user management, profile & password security, business/receipt settings, and configurable daily gold rates.

## Tech Stack

- **Backend:** PHP 8.2+, Laravel 11, Livewire 4
- **Frontend:** Tailwind CSS, Vite
- **Database:** MySQL

## Quick Setup (Local)

```bash
git clone https://github.com/webotapp-academy/Gold-Loan-Girvi-Management-Software.git
cd Gold-Loan-Girvi-Management-Software

composer install
npm install && npm run build

cp .env.example .env
php artisan key:generate
```

Configure your MySQL database in `.env`, then run migrations and seeders:

```bash
php artisan migrate --seed
php artisan db:seed --class=ExtraDemoDataSeeder
php artisan serve
```

## Docker Setup

### Prerequisites
- Docker & Docker Compose v2+

### 1. Configure Environment
Copy the Docker environment template and generate an application key:

```bash
cp .env.docker.example .env.docker
```

Generate a Laravel `APP_KEY` and set it in `.env.docker` (or run after building):

```bash
# Option A: Using OpenSSL on host
echo "APP_KEY=base64:$(openssl rand -base64 32)"
```

Update `APP_KEY`, `DB_PASSWORD`, and `DB_ROOT_PASSWORD` in `.env.docker` as needed.

### 2. Build & Start Containers

```bash
docker compose --env-file .env.docker up -d --build
```

This starts three services:
- **`web`** (`nginx:1.27-alpine`): Serves static/Vite assets and proxies PHP requests on `http://localhost:8080` (configurable via `APP_PORT`).
- **`app`** (`php:8.4-fpm-alpine`): Runs Laravel 11 + Livewire 4, automatically waits for MySQL, links storage, runs migrations (`RUN_MIGRATIONS=true`), and caches config/routes/views.
- **`db`** (`mysql:8.0`): Persistent MySQL database (`mysql_data` volume), also exposed on `127.0.0.1:3307` (configurable via `DB_FORWARD_PORT`).

### 3. Seed Demo Data (Optional)

```bash
docker compose --env-file .env.docker exec app php artisan db:seed --force
docker compose --env-file .env.docker exec app php artisan db:seed --class=ExtraDemoDataSeeder --force
```

### 4. Useful Docker Commands

```bash
# View logs
docker compose --env-file .env.docker logs -f

# Check container status & health
docker compose --env-file .env.docker ps

# Run artisan commands
docker compose --env-file .env.docker exec app php artisan migrate:status

# Stop containers (keeps database & storage volumes)
docker compose --env-file .env.docker down

# Stop and remove volumes (resets database)
docker compose --env-file .env.docker down -v
```

## Default Demo Credentials

- **Admin:** `admin@webotapp.com` / `admin123`
- **Staff:** `staff@webotapp.com` / `staff123`
