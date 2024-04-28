Caddy -> Nginx @ Port 80

# Restore latest backup (stored in /data/db)
docker compose down -v && docker compose up -d

# Restore from restic backup