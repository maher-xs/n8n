#!/bin/bash

# ==============================================
#        n8n Interactive Installer
#        For Ubuntu 20.04 / 22.04 / 24.04
# ==============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                                                       ║"
echo "║     ███╗   ██╗ █████╗ ███╗   ██╗                      ║"
echo "║     ████╗  ██║██╔══██╗████╗  ██║                      ║"
echo "║     ██╔██╗ ██║╚█████╔╝██╔██╗ ██║                      ║"
echo "║     ██║╚██╗██║██╔══██╗██║╚██╗██║                      ║"
echo "║     ██║ ╚████║╚█████╔╝██║ ╚████║                      ║"
echo "║     ╚═╝  ╚═══╝ ╚════╝ ╚═╝  ╚═══╝                      ║"
echo "║                                                       ║"
echo "║         🚀 n8n Auto Installer v1.0 🚀                 ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root: sudo bash n8n-installer.sh${NC}"
    exit 1
fi

# Check Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}❌ This script is for Ubuntu only!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Running as root${NC}"
echo -e "${GREEN}✓ Ubuntu detected${NC}"
echo ""

# ==============================================
#           GET USER INPUT
# ==============================================

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}                   CONFIGURATION                       ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Domain
DOMAIN=""
while [ -z "$DOMAIN" ]; do
    echo -e "${CYAN}📌 Enter your domain (e.g., n8n.example.com):${NC}"
    echo -n "   Domain: "
    read DOMAIN </dev/tty
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}   Domain cannot be empty!${NC}"
        echo ""
    fi
done

# Email
EMAIL=""
while [ -z "$EMAIL" ]; do
    echo ""
    echo -e "${CYAN}📧 Enter your email (for SSL certificate):${NC}"
    echo -n "   Email: "
    read EMAIL </dev/tty
    if [ -z "$EMAIL" ]; then
        echo -e "${RED}   Email cannot be empty!${NC}"
    fi
done

# Timezone
echo ""
echo -e "${CYAN}🌍 Select your timezone:${NC}"
echo "   1) Asia/Riyadh (Saudi Arabia)"
echo "   2) Asia/Dubai (UAE)"
echo "   3) Africa/Cairo (Egypt)"
echo "   4) Asia/Amman (Jordan)"
echo "   5) Asia/Kuwait (Kuwait)"
echo "   6) Europe/London (UK)"
echo "   7) America/New_York (USA East)"
echo "   8) UTC"
echo "   9) Custom"
echo -n "   Choose [1-9] (default: 1): "
read TZ_CHOICE </dev/tty

case $TZ_CHOICE in
    2) TIMEZONE="Asia/Dubai" ;;
    3) TIMEZONE="Africa/Cairo" ;;
    4) TIMEZONE="Asia/Amman" ;;
    5) TIMEZONE="Asia/Kuwait" ;;
    6) TIMEZONE="Europe/London" ;;
    7) TIMEZONE="America/New_York" ;;
    8) TIMEZONE="UTC" ;;
    9) 
        echo -n "   Enter timezone: "
        read TIMEZONE </dev/tty
        ;;
    *) TIMEZONE="Asia/Riyadh" ;;
esac

# Port
echo ""
echo -e "${CYAN}🔌 n8n internal port (default: 5678):${NC}"
echo -n "   Port: "
read PORT_INPUT </dev/tty
if [ -z "$PORT_INPUT" ]; then
    PORT=5678
else
    PORT=$PORT_INPUT
fi

# SSL Choice
echo ""
echo -e "${CYAN}🔒 Install SSL certificate?${NC}"
echo "   1) Yes - Let's Encrypt (recommended)"
echo "   2) No - HTTP only"
echo -n "   Choose [1-2] (default: 1): "
read SSL_CHOICE </dev/tty
if [ -z "$SSL_CHOICE" ]; then
    SSL_CHOICE=1
fi

# Basic Auth
echo ""
echo -e "${CYAN}🔐 Enable Basic Authentication? (extra security layer)${NC}"
echo "   1) No (n8n has its own login)"
echo "   2) Yes"
echo -n "   Choose [1-2] (default: 1): "
read AUTH_CHOICE </dev/tty
if [ -z "$AUTH_CHOICE" ]; then
    AUTH_CHOICE=1
fi

BASIC_USER=""
BASIC_PASS=""
if [ "$AUTH_CHOICE" == "2" ]; then
    echo -n "   Username: "
    read BASIC_USER </dev/tty
    echo -n "   Password: "
    read -s BASIC_PASS </dev/tty
    echo ""
fi

# ==============================================
#           CONFIRM SETTINGS
# ==============================================

if [ "$SSL_CHOICE" == "1" ]; then
    SSL_TEXT="${GREEN}Yes (Let's Encrypt)${NC}"
    PROTOCOL="https"
else
    SSL_TEXT="${RED}No (HTTP only)${NC}"
    PROTOCOL="http"
fi

if [ "$AUTH_CHOICE" == "2" ]; then
    AUTH_TEXT="${GREEN}Yes (User: $BASIC_USER)${NC}"
else
    AUTH_TEXT="No"
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}                 CONFIRM SETTINGS                      ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "   ${BLUE}Domain:${NC}     $DOMAIN"
echo -e "   ${BLUE}Email:${NC}      $EMAIL"
echo -e "   ${BLUE}Timezone:${NC}   $TIMEZONE"
echo -e "   ${BLUE}Port:${NC}       $PORT"
echo -e "   ${BLUE}SSL:${NC}        $SSL_TEXT"
echo -e "   ${BLUE}Basic Auth:${NC} $AUTH_TEXT"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -n "Continue with installation? [Y/n]: "
read CONFIRM </dev/tty
if [ -z "$CONFIRM" ]; then
    CONFIRM="Y"
fi

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 0
fi

# ==============================================
#           INSTALLATION
# ==============================================

echo ""
echo -e "${GREEN}🚀 Starting installation...${NC}"
echo ""

# Step 1: Update System
echo -e "${YELLOW}[1/10] 📦 Updating system...${NC}"
apt update && apt upgrade -y > /dev/null 2>&1
echo -e "${GREEN}   ✓ System updated${NC}"

# Step 2: Install dependencies
echo -e "${YELLOW}[2/10] 📦 Installing dependencies...${NC}"
apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https > /dev/null 2>&1
echo -e "${GREEN}   ✓ Dependencies installed${NC}"

# Step 3: Install Node.js
echo -e "${YELLOW}[3/10] 📦 Installing Node.js 18...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - > /dev/null 2>&1
apt install -y nodejs > /dev/null 2>&1
echo -e "${GREEN}   ✓ Node.js $(node -v) installed${NC}"

# Step 4: Install n8n
echo -e "${YELLOW}[4/10] 📦 Installing n8n...${NC}"
npm install -g n8n > /dev/null 2>&1
echo -e "${GREEN}   ✓ n8n installed${NC}"

# Step 5: Create user
echo -e "${YELLOW}[5/10] 👤 Creating n8n user...${NC}"
id -u n8n &>/dev/null || useradd -m -s /bin/bash n8n
mkdir -p /home/n8n/.n8n
chown -R n8n:n8n /home/n8n/.n8n
echo -e "${GREEN}   ✓ User created${NC}"

# Step 6: Create systemd service
echo -e "${YELLOW}[6/10] ⚙️  Creating systemd service...${NC}"
cat > /etc/systemd/system/n8n.service <<EOF
[Unit]
Description=n8n Workflow Automation
After=network.target

[Service]
Type=simple
User=n8n
Environment="N8N_HOST=${DOMAIN}"
Environment="N8N_PORT=${PORT}"
Environment="N8N_PROTOCOL=${PROTOCOL}"
Environment="WEBHOOK_URL=${PROTOCOL}://${DOMAIN}/"
Environment="N8N_SECURE_COOKIE=true"
Environment="GENERIC_TIMEZONE=${TIMEZONE}"
ExecStart=/usr/bin/n8n
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable n8n > /dev/null 2>&1
systemctl start n8n
echo -e "${GREEN}   ✓ Service created and started${NC}"

# Step 7: Install Nginx
echo -e "${YELLOW}[7/10] 📦 Installing Nginx...${NC}"
apt install -y nginx > /dev/null 2>&1
echo -e "${GREEN}   ✓ Nginx installed${NC}"

# Step 8: Configure Nginx
echo -e "${YELLOW}[8/10] ⚙️  Configuring Nginx...${NC}"

# Basic Auth setup if enabled
AUTH_CONFIG=""
if [ "$AUTH_CHOICE" == "2" ]; then
    apt install -y apache2-utils > /dev/null 2>&1
    htpasswd -cb /etc/nginx/.htpasswd "$BASIC_USER" "$BASIC_PASS" > /dev/null 2>&1
    AUTH_CONFIG='
        auth_basic "n8n Protected";
        auth_basic_user_file /etc/nginx/.htpasswd;'
fi

cat > /etc/nginx/sites-available/${DOMAIN} <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://localhost:${PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 300s;
        chunked_transfer_encoding off;${AUTH_CONFIG}
    }
}
EOF

ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t > /dev/null 2>&1
systemctl reload nginx
echo -e "${GREEN}   ✓ Nginx configured${NC}"

# Step 9: SSL Certificate
if [ "$SSL_CHOICE" == "1" ]; then
    echo -e "${YELLOW}[9/10] 🔒 Installing SSL certificate...${NC}"
    apt install -y certbot python3-certbot-nginx > /dev/null 2>&1
    certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL} --redirect > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✓ SSL certificate installed${NC}"
    else
        echo -e "${RED}   ✗ SSL failed - check DNS settings${NC}"
        PROTOCOL="http"
    fi
else
    echo -e "${YELLOW}[9/10] ⏭️  Skipping SSL...${NC}"
fi

# Step 10: Final setup
echo -e "${YELLOW}[10/10] 🔧 Final setup...${NC}"
systemctl restart n8n
sleep 3

# Open firewall
ufw allow 80 > /dev/null 2>&1
ufw allow 443 > /dev/null 2>&1

# Check status
if systemctl is-active --quiet n8n; then
    STATUS="${GREEN}✓ Running${NC}"
else
    STATUS="${RED}✗ Not Running${NC}"
fi

echo -e "${GREEN}   ✓ Installation complete${NC}"

# ==============================================
#           FINAL OUTPUT
# ==============================================

echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║        🎉 Installation Complete! 🎉                       ║"
echo "║                                                           ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo -e "${NC}"
echo -e "  🌐 ${CYAN}Access n8n at:${NC}"
echo -e "     ${GREEN}${PROTOCOL}://${DOMAIN}${NC}"
echo ""
if [ "$AUTH_CHOICE" == "2" ]; then
echo -e "  🔐 ${CYAN}Basic Auth:${NC}"
echo -e "     Username: ${BASIC_USER}"
echo -e "     Password: [hidden]"
echo ""
fi
echo -e "  📋 ${CYAN}Commands:${NC}"
echo -e "     Status:   ${YELLOW}systemctl status n8n${NC}"
echo -e "     Logs:     ${YELLOW}journalctl -u n8n -f${NC}"
echo -e "     Restart:  ${YELLOW}systemctl restart n8n${NC}"
echo -e "     Stop:     ${YELLOW}systemctl stop n8n${NC}"
echo ""
echo -e "  📁 ${CYAN}Data Directory:${NC} /home/n8n/.n8n"
echo ""
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "   n8n Status: ${STATUS}"
echo ""
echo -e "${CYAN}   Open your browser and create your admin account!${NC}"
echo ""
