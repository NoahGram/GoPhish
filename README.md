# GoPhish Phishing Simulation Infrastructure

Self-hosted phishing simulation environment built for security awareness training and human risk measurement. Designed to run realistic, controlled phishing campaigns as part of an organisational security awareness programme.

## Stack

| Component | Role |
|---|---|
| **GoPhish** | Campaign management, email tracking & analytics |
| **Caddy** | Reverse proxy, automatic TLS (HTTPS) |
| **Postmark** | SMTP relay for reliable email delivery |
| **Railway** | PaaS cloud hosting, CI/CD via GitHub |
| **Docker** | Containerised deployment |

## Architecture

```
Internet (targets)
      ↓
  Caddy — reverse proxy + automatic HTTPS
      ↓
GoPhish phishing server  (port 80)
GoPhish admin panel      (port 3333 — internal only)
```

Caddy routes traffic based on the HTTP Host header, keeping the admin panel isolated from the public phishing endpoint.

## Features

- **Self-hosted**: full data ownership, no third-party dependency
- **Automatic HTTPS**: Caddy handles TLS certificate provisioning
- **Persistent storage**: Railway volume mounted at `/userdata` to survive container restarts
- **Accurate IP logging**: `X-Forwarded-For` / `X-Real-IP` headers passed through to GoPhish
- **CI/CD**: every push to `main` triggers an automatic Railway redeploy
- **MITRE ATT&CK aligned**: campaign scenarios mapped to T1566.002 (Spearphishing Link) and T1056.002 (Credential Harvesting)

## Key Technical Challenges Solved

- **Redirect loop**: Railway terminates SSL at the edge and forwards plain HTTP internally; fixed with `auto_https off` in Caddyfile to prevent Caddy from re-forcing HTTPS
- **Volume permissions**: GoPhish migration scripts conflicted with the mounted volume; resolved by isolating the database to `/userdata` and setting `USER root` in the Dockerfile
- **SMTP egress filtering**: outbound SMTP port was blocked by PaaS egress rules; resolved by explicitly opening the required port

## Purpose

Built as part of a graduation project (HBO-ICT, Cybersecurity) focused on measuring and improving human security awareness through phishing simulations. The infrastructure supports ongoing campaign execution, results tracking and targeted security awareness training.

## Disclaimer

This project is built for **authorised security awareness testing only**. Do not use against systems or individuals without explicit written permission.
