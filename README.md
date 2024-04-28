Caddy -> Nginx @ Port 80

# Duplicate specific app
./duplicate.sh in folder

# Restore latest backup (stored in /data/db)
docker compose down -v && docker compose up -d

# Restore from restic backup

# Requirements

- Alpine Base setup
- caddy
- cronjobs
- restic
- watchtower