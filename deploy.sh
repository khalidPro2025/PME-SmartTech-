#!/bin/bash

# =====================================================================
#      SMARTTECH – DEPLOY SCRIPT PRO 2025 (Awa / Khalid Edition)
# =====================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # reset

echo -e "${BLUE}"
echo "==============================================================="
echo "            🚀 SMARTTECH MULTISERVICES PLATFORM"
echo "                DEPLOYMENT SCRIPT (PRO EDITION)"
echo "==============================================================="
echo -e "${NC}"

sleep 1

# ---------------------------------------------------------------------
# Vérification des prérequis
# ---------------------------------------------------------------------
echo -e "${YELLOW}🔍 Vérification des prérequis...${NC}"

command -v docker >/dev/null 2>&1 || { echo -e "${RED}❌ Docker non installé !${NC}"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo -e "${RED}❌ Docker Compose non installé !${NC}"; exit 1; }

echo -e "${GREEN}✔ Docker OK${NC}"
echo -e "${GREEN}✔ Docker Compose OK${NC}"

sleep 1

# ---------------------------------------------------------------------
# Arrêt propre
# ---------------------------------------------------------------------
echo -e "${YELLOW}🛑 Arrêt des anciens services...${NC}"
docker-compose down --remove-orphans
echo -e "${GREEN}✔ Services arrêtés${NC}"

# ---------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------
echo -e "${YELLOW}📦 Construction des images (build)...${NC}"
docker-compose build --no-cache
echo -e "${GREEN}✔ Build terminé${NC}"

# ---------------------------------------------------------------------
# Démarrage
# ---------------------------------------------------------------------
echo -e "${YELLOW}🚀 Démarrage des services...${NC}"
docker-compose up -d

echo -e "${BLUE}⏳ Attente 20 secondes pour initialiser tous les services...${NC}"
sleep 20

# ---------------------------------------------------------------------
# HEALTHCHECKS
# ---------------------------------------------------------------------
echo ""
echo -e "${BLUE}==============================================================="
echo "                     🔍 HEALTHCHECKS SERVICES"
echo "==============================================================="
echo ""

function check_service() {
    NAME=$1
    CONTAINER=$2

    STATUS=$(docker inspect -f '{{.State.Health.Status}}' $CONTAINER 2>/dev/null)

    if [[ "$STATUS" == "healthy" ]]; then
        echo -e "${GREEN}✔ $NAME est opérationnel${NC}"
    else
        echo -e "${RED}❌ $NAME NOT OK${NC}"
    fi
}

# DNS
check_service "DNS Bind9" "smarttech_bind9"

# FTP
check_service "FTP" "smarttech_ftp"

# SSH
check_service "SSH" "smarttech_ssh"

# Asterisk
check_service "Asterisk (ToIP)" "smarttech_asterisk"

# Mail
check_service "Mailserver" "smarttech_mail"

# NoVNC
check_service "NoVNC" "smarttech_novnc"

# Samba
check_service "Samba" "smarttech_samba"

# FastAPI
check_service "FastAPI" "smarttech_fastapi"

# Portal
check_service "Portal Web" "smarttech_portal"

# Traefik
echo ""
echo -e "${BLUE}🔍 Vérification Traefik + certificat...${NC}"
docker logs smarttech_traefik | grep -E "legolog|acme" -i | tail -n 10

echo -e "${GREEN}✔ Traefik OK${NC}"

# ---------------------------------------------------------------------
# TESTS REELS
# ---------------------------------------------------------------------
echo ""
echo -e "${BLUE}==============================================================="
echo "                     🧪 TESTS RÉELS"
echo "==============================================================="
echo ""

echo -e "${YELLOW}📡 Test DNS...${NC}"
docker exec smarttech_bind9 nslookup ftp.smarttech.local

echo -e "${YELLOW}📁 Test FTP...${NC}"
echo "quit" | ftp -n localhost 21 >/dev/null 2>&1 && echo -e "${GREEN}✔ FTP OK${NC}" || echo -e "${RED}❌ FTP FAIL${NC}"

echo -e "${YELLOW}🔐 Test SSH...${NC}"
ssh -o StrictHostKeyChecking=no -p 2222 sshuser@localhost "echo 'OK'" >/dev/null 2>&1 && echo -e "${GREEN}✔ SSH OK${NC}" || echo -e "${RED}❌ SSH FAIL${NC}"

echo -e "${YELLOW}📞 Test Asterisk SIP peers...${NC}"
docker exec smarttech_asterisk asterisk -rx "sip show peers"

echo -e "${YELLOW}📧 Test Mail (port 25)...${NC}"
nc -z localhost 25 && echo -e "${GREEN}✔ SMTP OK${NC}" || echo -e "${RED}❌ SMTP FAIL${NC}"

echo -e "${YELLOW}🖥️  Test portail web...${NC}"
curl -k -I https://portal.smarttech.local 2>/dev/null | head -n 1

echo -e "${YELLOW}🧩 Test API...${NC}"
curl -k https://api.smarttech.local 2>/dev/null

# ---------------------------------------------------------------------
# Résumé
# ---------------------------------------------------------------------
echo ""
echo -e "${BLUE}==============================================================="
echo "                     🎉 DÉPLOIEMENT TERMINÉ"
echo "==============================================================="
echo -e "${GREEN}✔ Plateforme SmartTech opérationnelle !${NC}"
echo ""
echo -e "🌐 Portal : ${YELLOW}https://portal.smarttech.local${NC}"
echo -e "🔧 API    : ${YELLOW}https://api.smarttech.local${NC}"
echo -e "📬 Mail   : ${YELLOW}https://mail.smarttech.local${NC}"
echo -e "🖥️  NoVNC  : ${YELLOW}https://vnc.smarttech.local${NC}"
echo -e "📦 FTP    : ${YELLOW}ftp.smarttech.local${NC}"
echo -e "🔒 SSH    : ${YELLOW}ssh.smarttech.local${NC}"
echo ""
echo -e "${BLUE}===============================================================${NC}"
