Caddy -> Nginx @ Port 80

# Restore latest backup (stored in /data/db)
docker compose down -v && docker compose up -d

# Restore from restic backup

# adminer
docker-compose --profile adminer up -d

docker-compose --profile adminer stop adminer


# Requirements

- Alpine Base setup
- caddy
- cronjobs
- restic
- watchtower