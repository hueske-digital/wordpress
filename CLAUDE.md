# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Dockerized WordPress environment with PHP-FPM, Nginx, MariaDB, and additional tools. The setup is designed for both development and production use with comprehensive configuration options.

## Key Commands

### Starting the Environment
```bash
docker compose up -d                    # Start all services
docker compose up -d --profile adminer  # Include Adminer database tool
docker compose up -d --profile ssh      # Include SSH server for deployments
```

### Managing WordPress
```bash
docker compose exec app wp <command>    # Run WP-CLI commands
docker compose exec app wp plugin list  # List installed plugins
docker compose exec app wp theme list   # List installed themes
docker compose exec app wp cron event list  # Check cron events
```

### Database Operations
```bash
docker compose exec db mariadb -u wordpress -p  # Access database CLI
docker compose logs db                           # View database logs
```

### Viewing Logs
```bash
docker compose logs -f app      # PHP-FPM logs
docker compose logs -f web      # Nginx logs
docker compose logs -f db       # MariaDB logs
```

### Building Custom Image
```bash
docker build -t wordpress-custom ./build/  # Build image locally
```

## Architecture & Structure

### Service Architecture
- **app**: WordPress PHP-FPM container (ghcr.io/hueske-digital/wordpress:latest)
  - Runs as user 1000:1000
  - Auto-reloads PHP-FPM when user.ini changes via watchexec
  - Includes WP-CLI, image optimization tools, and gomplate templating
  
- **web**: Nginx reverse proxy (unprivileged)
  - Handles HTTP requests and forwards to PHP-FPM
  - Includes 8G firewall configuration
  - Supports full-page caching via Perl module
  
- **db**: MariaDB database
  - Configurable performance settings via environment variables
  - Automatic backups via Ofelia cron jobs
  
- **adminer**: Database management UI (optional profile)
- **ssh**: OpenSSH server for deployments (optional profile)

### Directory Structure
- `build/`: Docker image build files and templates
  - Contains Dockerfile and gomplate templates for dynamic configuration
- `conf/`: Service configuration files
  - `nginx/`: Nginx configs including 8G firewall rules
  - `php/`: PHP configuration (user.ini)
  - `ssh/`: SSH server setup scripts
- `data/`: Persistent data volumes
  - `web/`: WordPress files (mounted to /var/www/html)
  - `db/`: Database initialization and backup files
- `keys/`: SSH public keys for deployment access

### Key Configuration Files
- `docker-compose.yml`: Main orchestration file with all service definitions
- `.env`: Environment variables (copy from .env.example)
- `conf/php/user.ini`: Custom PHP settings (copied from user.ini.example)
- `build/wp-config.tmpl`: WordPress configuration template processed by gomplate

### Environment Variables
Key variables from .env.example:
- Database: DB_HOST, DB_USER, DB_PASSWORD, DB_NAME
- WordPress: WORDPRESS_TABLE_PREFIX, WORDPRESS_CRON_SCHEDULE
- PHP-FPM: PHP_FPM_PM_* settings for process manager tuning
- MariaDB: MARIADB_INNODB_BUFFER_SIZE, MARIADB_MAX_CONNECTIONS
- SMTP: SMTP_USER, SMTP_PASS, SMTP_HOST for email configuration

### Cron Jobs (via Ofelia)
- WordPress cron: Runs wp-cron.php (default: every 5 minutes)
- Plugin/theme updates: Automatic updates (default: daily at 8 PM)
- Database backup: Daily backups to data/db/
- Database repair: Daily maintenance checks

### Network Architecture
- `app_db`: Internal network for app-database communication
- `app_web`: Internal network for web-app communication  
- `proxy_apps`: External network for reverse proxy integration

### Development Workflow
1. Copy `.env.example` to `.env` and configure
2. Copy `conf/php/user.ini.example` to `conf/php/user.ini` for custom PHP settings
3. WordPress files go in `data/web/`
4. PHP configuration changes in user.ini auto-reload PHP-FPM
5. Use WP-CLI via `docker compose exec app wp` for WordPress management