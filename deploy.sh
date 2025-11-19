#!/bin/bash

# =====================================================================
#           SMARTTECH – TEST SERVICES PRO (khalid Edition 2025)
# =====================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # reset

echo -e "${BLUE}"
echo "==============================================================="
echo "        🔍 SMARTTECH MULTISERVICES PLATFORM – TESTS ONLY"
echo "==============================================================="
echo -e "${NC}"

sleep 1

# ---------------------------------------------------------------------
# Verification d’UN conteneur avec Healthchecks
# ---------------------------------------------------------------------
function check_service() {
    NAME=$1
    CONTAINER=$2

    STATUS=$(docker inspect -f '{{.State.Health.Status}}' $CONTAINER 2>/dev/null)

    if [[ "$STATUS" == "healthy" ]]; then
        echo -e "${GREEN}✔ $NAME est HEALTHY${NC}"
    elif [[ "$STATUS" == "starting" ]]; then
        echo -e "${YELLOW}⚠ $NAME en démarrage...${NC}"
    elif [[ "$STATUS" == "unhealthy" ]]; then
        echo -e "${RED}❌ $NAME UNHEALTHY${NC}"
    else
        echo -e "${RED}❌ $NAME OFF ou sans healthcheck${NC}"
    fi
}

# ---------------------------------------------------------------------
# HEALTHCHECKS
# ---------------------------------------------------------------------
echo ""
echo -e "${BLUE}==============================================================="
echo "                    ✔ HEALTHCHECKS SERVICES"
echo "==============================================================="
echo ""

check_service "DNS Bind9" "smarttech_bind9"
check_service "FTP" "smarttech_ftp"
check_service "SSH" "smarttech_ssh"
check_service "Asterisk (ToIP)" "smarttech_asterisk"
check_service "Mailserver" "smarttech_mail"
check_service "NoVNC" "smarttech_novnc"
check_service "Samba" "smarttech_samba"
check_service "FastAPI" "smarttech_fastapi"
check_service "Portal Web" "smarttech_portal"
check_service "Traefik Proxy" "smarttech_traefik"

sleep 1

# ---------------------------------------------------------------------
# TESTS REELS (Services)
# ---------------------------------------------------------------------
echo ""
echo -e "${BLUE}==============================================================="
echo "                        🧪 TESTS RÉELS"
echo "==============================================================="
echo ""

echo -e "${YELLOW}📡 Test DNS (Bind9)...${NC}"
docker exec smarttech_bind9 nslookup ftp.smarttech.local

echo -e "${YELLOW}📁 Test FTP (port 21)...${NC}"
echo "quit" | ftp -n localhost 21 >/dev/null 2>&1 \
    && echo -e "${GREEN}✔ FTP OK${NC}" \
    || echo -e "${RED}❌ FTP FAIL${NC}"

echo -e "${YELLOW}🔐 Test SSH (port 2222)...${NC}"
ssh -o StrictHostKeyChecking=no -p 2222 sshuser@localhost "echo OK" >/dev/null 2>&1 \
    && echo -e "${GREEN}✔ SSH OK${NC}" \
    || echo -e "${RED}❌ SSH FAIL${NC}"

echo -e "${YELLOW}📞 Test Asterisk SIP peers...${NC}"
docker exec smarttech_asterisk asterisk -rx "sip show peers"

echo -e "${YELLOW}📧 Test Mail SMTP (port 25)...${NC}"
nc -z localhost 25 \
    && echo -e "${GREEN}✔ SMTP OK${NC}" \
    || echo -e "${RED}❌ SMTP FAIL${NC}"

echo -e "${YELLOW}🖥️  Test portail web (HTTPS)...${NC}"
curl -k -I https://portal.smarttech.local 2>/dev/null | head -n 1

echo -e "${YELLOW}🧩 Test API (FastAPI)...${NC}"
curl -k https://api.smarttech.local 2>/dev/null
echo ""

echo -e "${YELLOW}🗂 Test Samba (port 445)...${NC}"
nc -z localhost 445 \
    && echo -e "${GREEN}✔ SMB OK${NC}" \
    || echo -e "${RED}❌ SMB FAIL${NC}"

echo ""
echo -e "${BLUE}==============================================================="
echo "                  🎉 TEST TERMINÉ – RÉSULTAT GLOBAL"
echo "==============================================================="
echo -e "${GREEN}✔ Tous les tests ont été exécutés !${NC}"
echo ""
