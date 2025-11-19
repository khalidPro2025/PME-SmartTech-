#!/bin/bash

# =====================================================================
#     SMARTTECH – DIAGNOSTIC COMPLET (Logs + Erreurs + Healthchecks)
# =====================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SERVICES=(
    smarttech_bind9
    smarttech_ftp
    smarttech_ssh
    smarttech_asterisk
    smarttech_mail
    smarttech_novnc
    smarttech_samba
    smarttech_fastapi
    smarttech_portal
    smarttech_traefik
)

echo -e "${BLUE}"
echo "==============================================================="
echo "          🔍 SMARTTECH – DIAGNOSTIC GLOBAL DES SERVICES"
echo "==============================================================="
echo -e "${NC}"

echo ""

# ---------------------------------------------------------------------
# Healthcheck pour chaque conteneur
# ---------------------------------------------------------------------
echo -e "${YELLOW}✔ Vérification HEALTHCHECK pour chaque service...${NC}"

for S in "${SERVICES[@]}"; do
    STATUS=$(docker inspect -f '{{.State.Health.Status}}' $S 2>/dev/null)

    if [[ "$STATUS" == "healthy" ]]; then
        echo -e "  ${GREEN}✔ $S : HEALTHY${NC}"
    elif [[ "$STATUS" == "starting" ]]; then
        echo -e "  ${YELLOW}⚠ $S : STARTING${NC}"
    else
        echo -e "  ${RED}❌ $S : UNHEALTHY ou PAS DE HEALTHCHECK${NC}"
    fi
done

echo ""
echo -e "${BLUE}==============================================================="
echo "                    📜 LOGS RÉCENTS DES SERVICES"
echo "==============================================================="
echo ""

# ---------------------------------------------------------------------
# Logs récents (30 dernières lignes)
# ---------------------------------------------------------------------
for S in "${SERVICES[@]}"; do
    echo -e "${BLUE}===== 📘 LOGS : $S =====${NC}"
    docker logs --tail 30 $S 2>&1
    echo ""
done

# ---------------------------------------------------------------------
# Recherche automatique d’erreurs dans les logs
# ---------------------------------------------------------------------
echo ""
echo -e "${BLUE}==============================================================="
echo "                     ❌ ANALYSE DES ERREURS"
echo "==============================================================="
echo ""

for S in "${SERVICES[@]}"; do
    echo -e "${YELLOW}🔍 Erreurs détectées dans $S :${NC}"

    docker logs $S 2>&1 | grep -Ei "error|fail|fatal|panic|refused|invalid|warning" | tail -n 10

    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✔ Aucune erreur trouvée${NC}"
    fi

    echo ""
done

# ---------------------------------------------------------------------
# Résumé
# ---------------------------------------------------------------------
echo -e "${BLUE}==============================================================="
echo "                     🎉 DIAGNOSTIC TERMINÉ"
echo "==============================================================="
echo -e "${GREEN}✔ Tous les logs et erreurs ont été affichés.${NC}"
echo ""
echo -e "${YELLOW}Astuce : utilise 'docker logs -f <service>' pour suivre en direct.${NC}"
echo ""
