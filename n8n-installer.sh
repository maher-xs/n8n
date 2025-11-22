#!/bin/bash

# ==============================================
#        n8n Interactive Installer v2
#        For Ubuntu 20.04 / 22.04 / 24.04
#        Step by Step Installation
# ==============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to read input properly
ask() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    local result=""
    
    if [ -n "$default" ]; then
        echo -ne "${CYAN}${prompt}${NC} [${default}]: "
    else
        echo -ne "${CYAN}${prompt}${NC}: "
    fi
    
    read result < /dev/tty
    
    if [ -z "$result" ] && [ -n "$default" ]; then
        result="$default"
    fi
    
    eval "$var_name='$result'"
}

# Function to ask yes/no
ask_yn() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    local result=""
    
    echo -ne "${CYAN}${prompt}${NC} [${default}]: "
    read result < /dev/tty
    
    if [ -z "$result" ]; then
        result="$default"
    fi
    
    eval "$var_name='$result'"
}

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
echo "║         🚀 n8n Auto Installer v2.0 🚀                 ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root!${NC}"
    echo -e "${YELLOW}Use: sudo bash n8n-installer.sh${NC}"
    exit 1
fi

# Check Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo -e "${RED}❌ This script is for Ubuntu only!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Running as root${NC}"
echo -e "${GREEN}✓ Ubuntu detected${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}                   CONFIGURATION                       ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============ STEP 1: DOMAIN ============
echo -e "${GREEN}Step 1/6: Domain${NC}"
DOMAIN=""
while [ -z "$DOMAIN" ]; do
    ask "📌 Enter your domain (e.g., n8n.example.com)" "DOMAIN" ""
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}   ❌ Domain cannot be empty! Try again.${NC}"
        echo ""
    fi
done
echo -e "${GREEN}   ✓ Domain: ${DOMAIN}${NC}"
echo ""

# ============ STEP 2: EMAIL ============
echo -e "${GREEN}Step 2/6: Email${NC}"
EMAIL=""
while [ -z "$EMAIL" ]; do
    ask "📧 Enter your email (for SSL certificate)" "EMAIL" ""
    if [ -z "$EMAIL" ]; then
        echo -e "${RED}   ❌ Email cannot be empty! Try again.${NC}"
        echo ""
    fi
done
echo -e "${GREEN}   ✓ Email: ${EMAIL}${NC}"
echo ""

# ============ STEP 3: TIMEZONE ============
echo -e "${GREEN}Step 3/6: Timezone${NC}"
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
ask "   Choose" "TZ_CHOICE" "1"

case $TZ_CHOICE in
    1) TIMEZONE="Asia/Riyadh" ;;
    2) TIMEZONE="Asia/Dubai" ;;
    3) TIMEZONE="Africa/Cairo" ;;
    4) TIMEZONE="Asia/Amman" ;;
    5) TIMEZONE="Asia/Kuwait" ;;
    6) TIMEZONE="Europe/London" ;;
    7) TIMEZONE="America/New_York" ;;
    8) TIMEZONE="UTC" ;;
    9) ask "   Enter custom timezone" "TIMEZONE" "UTC" ;;
    *) TIMEZONE="Asia/Riyadh" ;;
esac
echo -e "${GREEN}   ✓ Timezone: ${TIMEZONE}${NC}"
echo ""

# ============ STEP 4: PORT ============
echo -e "${GREEN}Step 4/6: Port${NC}"
ask "🔌 n8n internal port" "PORT" "5678"
echo -e "${GREEN}   ✓ Port: ${PORT}${NC}"
echo ""

# ============ STEP 5: SSL ============
echo -e "${GREEN}Step 5/6: SSL Certificate${NC}"
echo -e "${CYAN}🔒 Install SSL certificate (HTTPS)?${NC}"
echo "   1) Yes - Let's Encrypt (recommended)"
echo "   2) No - HTTP only"
ask "   Choose" "SSL_CHOICE" "1"

if [ "$SSL_CHOICE" == "1" ]; then
    PROTOCOL="https"
    SSL_TEXT="${GREEN}Yes (Let's Encrypt)${NC}"
else
    PROTOCOL="http"
    SSL_TEXT="${YELLOW}No (HTTP only)${NC}"
fi
echo -e "${GREEN}   ✓ SSL: ${SSL_TEXT}${NC}"
echo ""

# ============ STEP 6: BASIC AUTH ============
echo -e "${GREEN}Step 6/6: Basic Authentication${NC}"
echo -e "${CYAN}🔐 Enable Basic Auth? (extra security layer)${NC}"
echo "   1) No - n8n has its own login"
echo "   2) Yes - Add extra password protection"
ask "   Choose" "AUTH_CHOICE" "1"

BASIC_USER=""
BASIC_PASS=""
if [ "$AUTH_CHOICE" == "2" ]; then
    echo ""
    ask "   Enter username" "BASIC_USER" "admin"
    echo -ne "${CYAN}   Enter password${NC}: "
    read -s BASIC_PASS < /dev/tty
    echo ""
    AUTH_TEXT="${GREEN}Yes (User: ${BASIC_USER})${NC}"
else
    AUTH_TEXT="No"
fi
echo -e "${GREEN}   ✓ Basic Auth: ${AUTH_TEXT}${NC}"
echo ""

# ==============================================
#           CONFIRM SETTINGS
# ==============================================

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}                 CONFIRM SETTINGS                      ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "   ${BLUE}Domain:${NC}     ${GREEN}$DOMAIN${NC}"
echo -e "   ${BLUE}Email:${NC}      ${GREEN}$EMAIL${NC}"
echo -e "   ${BLUE}Timezone:${NC}   ${GREEN}$TIMEZONE${NC}"
echo -e "   ${BLUE}Port:${NC}       ${GREEN}$PORT${NC}"
echo -e "   ${BLUE}SSL:${NC}        $SSL_TEXT"
echo -e "   ${BLUE}Basic Auth:${NC} $AUTH_TEXT"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

ask_yn "🚀 Start installation?" "CONFIRM" "Y"

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Installation cancelled.${NC}"
    exit 0
fi

# ==============================================
#           INSTALLATION
# ==============================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              STARTING INSTALLATION                    ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1: Update System
echo -ne "${YELLOW}[1/10] 📦 Updating system...${NC}"
apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1
echo -e "\r${GREEN}[1/10] ✓ System updated                    ${NC}"

# Step 2: Install dependencies
echo -ne "${YELLOW}[2/10] 📦 Installing dependencies...${NC}"
apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https > /dev/null 2>&1
echo -e "\r${GREEN}[2/10] ✓ Dependencies installed            ${NC}"

# Step 3: Install Node.js
echo -ne "${YELLOW}[3/10] 📦 Installing Node.js 18...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x 2>/dev/null | bash - > /dev/null 2>&1
apt install -y nodejs > /dev/null 2>&1
NODE_VER=$(node -v 2>/dev/null || echo "unknown")
echo -e "\r${GREEN}[3/10] ✓ Node.js ${NODE_VER} installed          ${NC}"

# Step 4: Install n8n
echo -ne "${YELLOW}[4/10] 📦 Installing n8n (this may take a while)...${NC}"
npm install -g n8n > /dev/null 2>&1
echo -e "\r${GREEN}[4/10] ✓ n8n installed                           ${NC}"

# Step 5: Create user
echo -ne "${YELLOW}[5/10] 👤 Creating n8n user...${NC}"
id -u n8n &>/dev/null || useradd -m -s /bin/bash n8n
mkdir -p /home/n8n/.n8n
chown -R n8n:n8n /home/n8n/.n8n
echo -e "\r${GREEN}[5/10] ✓ n8n user created              ${NC}"

# Step 6: Create systemd service
echo -ne "${YELLOW}[6/10] ⚙️  Creating systemd service...${NC}"
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
echo -e "\r${GREEN}[6/10] ✓ Systemd service created         ${NC}"

# Step 7: Install Nginx
echo -ne "${YELLOW}[7/10] 📦 Installing Nginx...${NC}"
apt install -y nginx > /dev/null 2>&1
echo -e "\r${GREEN}[7/10] ✓ Nginx installed              ${NC}"

# Step 8: Configure Nginx
echo -ne "${YELLOW}[8/10] ⚙️  Configuring Nginx...${NC}"

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
echo -e "\r${GREEN}[8/10] ✓ Nginx configured              ${NC}"

# Step 9: SSL Certificate
if [ "$SSL_CHOICE" == "1" ]; then
    echo -ne "${YELLOW}[9/10] 🔒 Installing SSL certificate...${NC}"
    apt install -y certbot python3-certbot-nginx > /dev/null 2>&1
    certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL} --redirect > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\r${GREEN}[9/10] ✓ SSL certificate installed       ${NC}"
    else
        echo -e "\r${RED}[9/10] ✗ SSL failed (check DNS!)         ${NC}"
        PROTOCOL="http"
    fi
else
    echo -e "${YELLOW}[9/10] ⏭️  Skipping SSL (HTTP only)${NC}"
fi

# Step 10: Final setup
echo -ne "${YELLOW}[10/10] 🔧 Final setup...${NC}"
systemctl restart n8n
sleep 3
ufw allow 80 > /dev/null 2>&1
ufw allow 443 > /dev/null 2>&1

if systemctl is-active --quiet n8n; then
    STATUS="${GREEN}✓ Running${NC}"
else
    STATUS="${RED}✗ Not Running${NC}"
fi
echo -e "\r${GREEN}[10/10] ✓ Final setup complete          ${NC}"

# ==============================================
#           FINAL OUTPUT
# ==============================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║        🎉 INSTALLATION COMPLETE! 🎉                       ║"
echo "║                                                           ║"
echo -e "╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  🌐 ${CYAN}Your n8n is ready at:${NC}"
echo -e "     ${GREEN}${PROTOCOL}://${DOMAIN}${NC}"
echo ""
if [ "$AUTH_CHOICE" == "2" ]; then
echo -e "  🔐 ${CYAN}Basic Auth Credentials:${NC}"
echo -e "     Username: ${GREEN}${BASIC_USER}${NC}"
echo -e "     Password: ${GREEN}[as you set]${NC}"
echo ""
fi
echo -e "  📋 ${CYAN}Useful Commands:${NC}"
echo -e "     Check status:  ${YELLOW}systemctl status n8n${NC}"
echo -e "     View logs:     ${YELLOW}journalctl -u n8n -f${NC}"
echo -e "     Restart n8n:   ${YELLOW}systemctl restart n8n${NC}"
echo -e "     Stop n8n:      ${YELLOW}systemctl stop n8n${NC}"
echo ""
echo -e "  📁 ${CYAN}Data location:${NC} /home/n8n/.n8n"
echo ""
echo -e "  ⚡ ${CYAN}n8n Status:${NC} ${STATUS}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Open your browser and create your admin account! 🚀${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
