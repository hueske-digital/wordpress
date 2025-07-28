.PHONY: help up down restart logs shell wp backup restore clean build push

# Default target
help:
	@echo "WordPress Docker Management"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  up           Start all services"
	@echo "  down         Stop all services"
	@echo "  restart      Restart all services"
	@echo "  logs         Follow logs from all services"
	@echo "  shell        Open shell in WordPress container"
	@echo "  wp           Run WP-CLI commands (usage: make wp cmd='plugin list')"
	@echo "  backup       Create database backup"
	@echo "  restore      Restore database from backup (usage: make restore file=backup.sql)"
	@echo "  clean        Remove all containers, volumes and images"
	@echo "  build        Build Docker image locally"
	@echo "  push         Build and push Docker image"

# Start services
up:
	docker compose up -d

# Stop services
down:
	docker compose down

# Restart services
restart: down up

# Show logs
logs:
	docker compose logs -f

# Open shell in WordPress container
shell:
	docker compose exec app bash

# Run WP-CLI commands
wp:
ifndef cmd
	@echo "Error: Please specify a WP-CLI command"
	@echo "Usage: make wp cmd='plugin list'"
	@exit 1
endif
	docker compose exec app wp $(cmd)

# Create database backup
backup:
	@mkdir -p backups
	@echo "Creating database backup..."
	@docker compose exec db mariadb-dump \
		-u$${DB_USER:-wordpress} \
		-p$${DB_PASSWORD:-wordpress} \
		$${DB_NAME:-wordpress} > backups/backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "Backup created in backups/ directory"

# Restore database from backup
restore:
ifndef file
	@echo "Error: Please specify a backup file"
	@echo "Usage: make restore file=backups/backup-20240101-120000.sql"
	@exit 1
endif
	@echo "Restoring database from $(file)..."
	@docker compose exec -T db mariadb \
		-u$${DB_USER:-wordpress} \
		-p$${DB_PASSWORD:-wordpress} \
		$${DB_NAME:-wordpress} < $(file)
	@echo "Database restored successfully"

# Clean everything
clean:
	docker compose down -v
	docker rmi ghcr.io/hueske-digital/wordpress:latest || true
	rm -rf data/web/* data/db/*
	@echo "All containers, volumes and data have been removed"

# Build image locally
build:
	docker build -t ghcr.io/hueske-digital/wordpress:latest ./build/

# Build and push image
push: build
	docker push ghcr.io/hueske-digital/wordpress:latest

# Development shortcuts
.PHONY: dev-up dev-down dev-logs

dev-up:
	docker compose --profile adminer up -d

dev-down:
	docker compose --profile adminer down

dev-logs:
	docker compose logs -f app web

# Maintenance tasks
.PHONY: update-plugins update-themes update-all clear-cache

update-plugins:
	docker compose exec app wp plugin update --all

update-themes:
	docker compose exec app wp theme update --all

update-all: update-plugins update-themes
	docker compose exec app wp language plugin --all update
	docker compose exec app wp language theme --all update
	docker compose exec app wp language core update

clear-cache:
	docker compose exec app wp cache flush