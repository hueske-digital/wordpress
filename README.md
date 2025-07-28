# WordPress Docker Environment

A production-ready Docker setup for WordPress with PHP-FPM, Nginx, MariaDB, and comprehensive tooling for development and deployment.

## Features

- **WordPress**: Latest version with customizable database and table prefix
- **PHP-FPM**: Performance-optimized with auto-reload on configuration changes
- **Nginx**: Unprivileged setup with 8G firewall and full-page caching support
- **MariaDB**: Tunable database with automatic backups and maintenance
- **WP-CLI**: Pre-installed for command-line WordPress management
- **Image Optimization**: Includes svgcleaner, optipng, pngquant, jpegoptim, and more
- **Automated Tasks**: Cron jobs via Ofelia for updates, backups, and maintenance
- **Development Tools**: Adminer for database management (optional)
- **Deployment**: SSH server with rsync support (optional)
- **Email**: SMTP configuration via msmtp

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
   docker compose up -d
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
  - Features: 8G firewall, full-page caching, unprivileged mode

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

### WP-CLI Commands

```bash
# List plugins
docker compose exec app wp plugin list

# Update all plugins
docker compose exec app wp plugin update --all

# Install a theme
docker compose exec app wp theme install twentytwentyfour --activate

# Check cron events
docker compose exec app wp cron event list
```

### Database Management

```bash
# Access MariaDB CLI
docker compose exec db mariadb -u wordpress -p

# Manual backup
docker compose exec db sh -c 'mariadb-dump -u wordpress -p wordpress > /docker-entrypoint-initdb.d/manual-backup.sql'
```

### Logs

```bash
# View all logs
docker compose logs -f

# Specific service logs
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

To build the WordPress image locally:

```bash
cd build
docker build -t my-wordpress .
```

Update `docker-compose.yml` to use your custom image.

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