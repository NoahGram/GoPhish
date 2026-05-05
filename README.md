# Gophish + Caddy Docker Setup

Complete phishing campaign infrastructure with Gophish backend and Caddy reverse proxy.

## Architecture

```
Internet (victims)
    ↓
Caddy (port 80/443)
    ↓
Gophish (phishing server on port 80)
    ↓
Gophish Admin Panel (port 3333 - local only)
```

## Setup Instructions

### 1. Prerequisites
- Docker & Docker Compose installed
- A domain name (or local testing setup)
- Gophish files in `./gophish/data/`

### 2. Configuration

#### Update the domain name in Caddyfile:
Edit `caddy/Caddyfile` and replace `phish.example.com` with your actual domain:

```caddy
phish.your-domain.com {
    reverse_proxy gophish:80 {
        header_up X-Forwarded-For {http.request.remote.host}
        header_up X-Forwarded-Proto {http.request.proto}
        header_up X-Real-IP {http.request.remote.host}
    }
    encode zstd gzip
}
```

#### Update DNS records:
Point your domain to your thinkstation's IP address:
```
phish.your-domain.com  A  YOUR_IP_ADDRESS
```

### 3. Running the Setup

#### Start services:
```bash
docker-compose up -d
```

#### Check logs:
```bash
# Gophish logs
docker-compose logs -f gophish

# Caddy logs
docker-compose logs -f caddy
```

#### Access Gophish Admin Panel:
```
https://localhost:3333
```
Default credentials: admin / gophish

#### Stop services:
```bash
docker-compose down
```

## File Structure

```
.
├── docker-compose.yml      # Docker services definition
├── caddy/
│   └── Caddyfile          # Caddy reverse proxy config
├── gophish/
│   ├── config.json        # Gophish configuration
│   ├── data/              # Gophish database and files
│   │   └── gophish.db     # SQLite database
│   └── Phishing_Simulation_Setup_Guide.md
└── .env                   # Environment variables
```

## Workflow

1. **Start Docker**: `docker-compose up -d`
2. **Access Admin**: https://localhost:3333
3. **Create Campaign**: Set landing page URL to `https://phish.your-domain.com`
4. **Send Emails**: Via your Azure tenant with Defender
5. **Track Results**: View analytics in Gophish admin panel
6. **Stop**: `docker-compose down`

## Important Notes

- ⚠️ **Legal**: This tool is for authorized security testing only
- The admin panel (port 3333) is NOT exposed to the internet (localhost only)
- Landing pages are served via HTTPS (Caddy handles SSL/TLS via Let's Encrypt)
- Gophish database persists in `gophish/data/`
- Caddy automatically handles certificate renewal

## Troubleshooting

### Landing page not accessible:
- Check DNS records point to your IP
- Verify firewall allows port 80/443
- Check `docker-compose logs caddy`

### Admin panel not accessible:
- Admin is on port 3333, only accessible on localhost
- If on different machine, use SSH tunnel:
  ```bash
  ssh -L 3333:localhost:3333 user@your-thinkstation
  ```

### Gophish not receiving traffic:
- Verify Caddyfile domain matches your actual domain
- Check `docker-compose logs gophish`
- Ensure phishing server is listening on 0.0.0.0:80 in config.json

## Security Best Practices

✅ Admin panel only accessible locally
✅ TLS/SSL automatically managed by Caddy
✅ Separate network for services
✅ Proper headers for tracking (X-Forwarded-For, etc.)
✅ Service restart policies

## Next Steps

1. Update `caddy/Caddyfile` with your domain
2. Verify `gophish/config.json` settings
3. Run `docker-compose up -d`
4. Access admin panel at https://localhost:3333
5. Import your landing page templates
6. Configure SMTP settings
7. Launch campaigns
