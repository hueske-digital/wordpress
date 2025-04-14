# WordPress Dockerized Environment

This repository provides a Dockerized setup for running a WordPress environment with PHP-FPM, Nginx, and MariaDB. It includes additional tools and configurations for development and production use.

## Features

- **WordPress**: Latest WordPress version with customizable database and table prefix.
- **PHP-FPM**: Configured with performance optimizations, error logging, and `user.ini` auto-reload when changes are detected. PHP-FPM settings are configurable via environment variables.
- **Nginx**: Unprivileged Nginx setup with custom configurations like nginx full page cache.
- **MariaDB**: Database server with tunable settings for performance.
- **Adminer**: Database management tool (optional).
- **SSH Server**: For secure file access and deployment.
- **WP-CLI**: Pre-installed for managing WordPress via the command line.
- **Cron Jobs**: Automated tasks using Ofelia.
- **File Watching**: Automatic PHP-FPM reload on configuration changes.
- **Image Optimization**: Tools like `svgcleaner`, `optipng`, `pngquant`, and `jpegoptim` included.