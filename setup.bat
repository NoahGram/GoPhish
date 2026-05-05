@echo off
REM Gophish + Caddy Docker Setup Helper Script for Windows

setlocal enabledelayedexpansion

echo.
echo 🚀 Gophish + Caddy Docker Setup
echo ================================
echo.

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed. Please install Docker Desktop for Windows first.
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not installed. Please install Docker Desktop for Windows first.
    pause
    exit /b 1
)

echo ✅ Docker and Docker Compose found
echo.

REM Get domain from user
set /p DOMAIN="Enter your phishing domain (e.g., phish.example.com): "

if "!DOMAIN!"=="" (
    echo ❌ Domain cannot be empty
    pause
    exit /b 1
)

REM Update Caddyfile using PowerShell
echo.
echo Updating Caddyfile with domain: !DOMAIN!
powershell -Command "(Get-Content caddy\Caddyfile) -replace 'phish.example.com', '!DOMAIN!' | Set-Content caddy\Caddyfile"

REM Start containers
echo.
echo Starting Docker containers...
docker-compose up -d

REM Wait for services
echo.
echo Waiting for services to start...
timeout /t 5 /nobreak

REM Show status
echo.
echo ✅ Setup complete!
echo.
echo 📋 Next steps:
echo 1. Access Gophish Admin: https://localhost:3333
echo    Default: admin / gophish
echo.
echo 2. Update your DNS records:
echo    !DOMAIN!  A  YOUR_THINKSTATION_IP
echo.
echo 3. Configure SMTP and create campaigns
echo.
echo 4. Landing page will be served at: https://!DOMAIN!
echo.
echo 📊 Useful commands:
echo    docker-compose logs -f                  (View all logs)
echo    docker-compose logs -f gophish         (View Gophish logs)
echo    docker-compose logs -f caddy           (View Caddy logs)
echo    docker-compose down                    (Stop services)
echo    docker-compose restart                 (Restart services)
echo.
pause
