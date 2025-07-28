# WordPress Docker Environment

A production-ready Docker setup for WordPress with PHP-FPM, Nginx, MariaDB, and comprehensive tooling for development and deployment.

## Features

- **WordPress**: Latest version with customizable database and table prefix
- **PHP-FPM**: Performance-optimized with auto-reload on configuration changes
- **Nginx**: Unprivileged setup with 8G firewall, enhanced caching, and static file optimization
- **MariaDB**: Tunable database with automatic backups and maintenance
- **WP-CLI**: Pre-installed for command-line WordPress management
- **Image Optimization**: Includes svgcleaner, optipng, pngquant, jpegoptim, and more
- **Automated Tasks**: Cron jobs via Ofelia for updates, backups, and maintenance
- **Development Tools**: Adminer for database management (optional)
- **Deployment**: SSH server with rsync support (optional)
- **Email**: SMTP configuration via msmtp
- **Makefile**: Simplified Docker commands for common tasks

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/hueske-digital/wordpress.git
   cd wordpress
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. **Set up PHP configuration** (optional)
   ```bash
   cp conf/php/user.ini.example conf/php/user.ini
   # Edit user.ini for custom PHP settings
   ```

4. **Start the services**
   ```bash
   make up
   # Or without Makefile: docker compose up -d
   ```

5. **Access WordPress**
   - Open http://localhost in your browser
   - Complete the WordPress installation

## Configuration

### Environment Variables

Key variables in `.env`:

| Variable                      | Description                | Default                |
|-------------------------------|----------------------------|------------------------|
| `DB_HOST`                     | Database hostname          | `db`                   |
| `DB_USER`                     | Database username          | `wordpress`            |
| `DB_PASSWORD`                 | Database password          | `wordpress`            |
| `DB_NAME`                     | Database name              | `wordpress`            |
| `WORDPRESS_TABLE_PREFIX`      | WordPress table prefix     | `wp_`                  |
| `PHP_FPM_PM_MAX_CHILDREN`     | PHP-FPM max processes      | `8`                    |
| `MARIADB_INNODB_BUFFER_SIZE`  | InnoDB buffer size         | `128M`                 |
| `SMTP_HOST`                   | SMTP server for emails     | `mail.agenturserver.de`|

See `.env.example` for all available options.

### PHP Configuration

Custom PHP settings can be added to `conf/php/user.ini`. Changes are automatically detected and PHP-FPM will reload within 250ms.

Example settings:
```ini
memory_limit = 512M
upload_max_filesize = 256M
post_max_size = 256M
```

## Services

### Core Services

- **app**: WordPress with PHP-FPM
  - Image: `ghcr.io/hueske-digital/wordpress:latest`
  - User: `1000:1000`
  - Features: WP-CLI, image optimization tools, auto-reload

- **web**: Nginx reverse proxy
  - Image: `nginxinc/nginx-unprivileged:mainline-alpine-perl`
  - Features: 8G firewall, enhanced FastCGI caching, static file optimization, unprivileged mode
  - Cache: 100MB cache size, 12-hour cache validity, cache status headers

- **db**: MariaDB database
  - Image: `mariadb:latest`
  - Features: Automatic backups, performance tuning, health checks

### Optional Services

Enable with Docker Compose profiles:

- **adminer**: Database management UI
  ```bash
  docker compose --profile adminer up -d
  ```

- **ssh**: SSH server for deployments
  ```bash
  docker compose --profile ssh up -d
  ```

## Usage

### Makefile Commands

The project includes a Makefile for common tasks:

```bash
make help         # Show all available commands
make up           # Start all services
make down         # Stop all services
make restart      # Restart all services
make logs         # Follow logs from all services
make shell        # Open shell in WordPress container
make wp cmd='plugin list'  # Run WP-CLI commands
make backup       # Create database backup
make restore file=backup.sql  # Restore database
make update-all   # Update all plugins, themes, and languages
make clean        # Remove all containers, volumes and images
```

### WP-CLI Commands

```bash
# Using Makefile
make wp cmd='plugin list'
make wp cmd='theme install twentytwentyfour --activate'

# Using Docker directly
docker compose exec app wp plugin list
docker compose exec app wp plugin update --all
docker compose exec app wp theme install twentytwentyfour --activate
docker compose exec app wp cron event list
```

### Database Management

```bash
# Using Makefile
make backup                    # Creates timestamped backup in backups/
make restore file=backups/backup-20240101-120000.sql

# Using Docker directly
docker compose exec db mariadb -u wordpress -p
docker compose exec db sh -c 'mariadb-dump -u wordpress -p wordpress > /docker-entrypoint-initdb.d/manual-backup.sql'
```

### Logs

```bash
# Using Makefile
make logs         # All services
make dev-logs     # Only app and web services

# Using Docker directly
docker compose logs -f
docker compose logs -f app    # PHP-FPM
docker compose logs -f web    # Nginx
docker compose logs -f db     # MariaDB
```

## Automated Tasks

The following tasks run automatically via Ofelia:

| Task                  | Schedule         | Description                         |
|-----------------------|------------------|-------------------------------------|
| WordPress Cron        | Every 5 minutes  | Executes wp-cron.php                |
| Plugin/Theme Updates  | Daily at 8 PM    | Updates all plugins and themes      |
| Database Backup       | Daily at 3 AM    | Backs up to `data/db/backup.sql`   |
| Database Repair       | Daily at 6 AM    | Checks and repairs database tables  |

## Directory Structure

```
.
├── build/              # Docker image build files
│   ├── Dockerfile      # Custom WordPress image
│   └── *.tmpl          # Configuration templates
├── conf/               # Service configurations
│   ├── nginx/          # Nginx configs and firewall rules
│   ├── php/            # PHP configuration
│   └── ssh/            # SSH server setup
├── data/               # Persistent data
│   ├── web/            # WordPress files
│   └── db/             # Database backups
├── keys/               # SSH public keys
├── docker-compose.yml  # Service definitions
├── Makefile            # Common Docker commands
└── .env.example        # Environment template
```

## Security

- Nginx runs as unprivileged user
- 8G firewall enabled by default
- WordPress runs as non-root user (1000:1000)
- Database credentials isolated via environment variables
- SSH access via public key only (no passwords)
- Automatic security updates for plugins/themes

## Building Custom Image

The WordPress image uses a multi-stage build for optimization:
- Stage 1: Builds svgcleaner from Rust
- Stage 2: Downloads watchexec and WP-CLI in a minimal Alpine container
- Stage 3: Assembles the final image with all components

To build locally:

```bash
make build
# Or manually:
cd build
docker build -t ghcr.io/hueske-digital/wordpress:latest .
```

The image automatically detects the target architecture (amd64/arm64) and downloads the appropriate watchexec binary.

## Deployment

### Using SSH (Optional)

1. Enable SSH profile:
   ```bash
   docker compose --profile ssh up -d
   ```

2. Add public keys to `keys/` directory

3. Connect via SSH:
   ```bash
   ssh -p 2222 deploymentuser@localhost
   ```

### GitHub Actions

The repository includes a workflow that automatically builds and pushes the Docker image to GitHub Container Registry on push to main branch.

## Troubleshooting

### PHP-FPM not reloading
Check watchexec logs:
```bash
docker compose logs app | grep watchexec
```

### Database connection errors
Verify credentials:
```bash
docker compose exec app wp config get DB_HOST
docker compose exec app wp config get DB_NAME
```

### Permission issues
Ensure files are owned by user 1000:
```bash
sudo chown -R 1000:1000 data/web
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Create an issue on [GitHub](https://github.com/hueske-digital/wordpress/issues)
- Check the [Wiki](https://github.com/hueske-digital/wordpress/wiki) for detailed guides

## Credits

Built with ❤️ by [hueske.digital](https://hueske.digital)