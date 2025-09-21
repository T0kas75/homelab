# Homelab (tokas.com.ua)

Infra managed with Docker Compose + Traefik + Mailcow.

## Live paths
- /opt/homestack (reverse proxy, nextcloud, sftpgo)
- /opt/mailcow (mailcow stack)

## DO NOT COMMIT
- Secrets go in .env.local files next to compose files
- Volumes/data/ACME files are ignored

## Deploy notes
- After editing compose or overrides:
    docker compose up -d
- Traefik changes:
    (cd /opt/homestack && docker compose up -d traefik)
- Mailcow changes:
    (cd /opt/mailcow && docker compose up -d)
