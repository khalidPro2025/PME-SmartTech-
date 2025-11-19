#!/bin/bash
# ============================================================
# Script de déploiement automatique GitHub + SSH
# Projet  : PME-SmartTech-
# Auteur  : Khalid Pro
# ============================================================

set -e

# === Variables ===
GIT_USER="khalidPro2025"
REPO_NAME="PME-SmartTech-"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"
SSH_EMAIL="${GIT_USER}@github.com"
REMOTE_URL="git@github.com:${GIT_USER}/${REPO_NAME}.git"
BRANCH="main"

echo ""
echo "[INIT] Démarrage du déploiement automatique vers GitHub..."
echo "================================================================"

# === Étape 1 : Génération de clé SSH si absente ===
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "[SSH] Aucune clé trouvée — génération d'une nouvelle..."
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY_PATH" -N ""
else
    echo "[SSH] Clé SSH existante détectée : $SSH_KEY_PATH"
fi

# === Étape 2 : Démarrage de l'agent SSH ===
echo "[SSH] Chargement de la clé dans l'agent SSH..."
eval "$(ssh-agent -s)" > /dev/null
ssh-add "$SSH_KEY_PATH"

# === Étape 3 : Test connexion GitHub ===
echo "[TEST] Vérification de la connexion SSH à GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "[SSH] Connexion GitHub réussie."
else
    echo "[SSH] Connexion échouée."
    echo "Ajoute cette clé publique dans GitHub :"
    echo "-------------------------------------------------"
    cat "$SSH_PUB_KEY"
    echo "-------------------------------------------------"
    echo "Lien : https://github.com/settings/keys"
    exit 1
fi

# === Étape 4 : Initialisation du dépôt si nécessaire ===
if [ ! -d ".git" ]; then
    echo "[GIT] Aucun dépôt détecté — initialisation..."
    git init
    git branch -M main
fi

# === Étape 5 : Configuration du remote ===
echo "[GIT] Configuration du remote origin (SSH)..."

if git remote -v | grep -q "$REMOTE_URL"; then
    echo "Remote déjà configuré."
else
    git remote remove origin 2>/dev/null || true
    git remote add origin "$REMOTE_URL"
    echo "Nouveau remote SSH ajouté."
fi

# === Étape 6 : Ajout et commit des fichiers ===
echo "[GIT] Ajout des changements..."
git add .

if git diff-index --quiet HEAD --; then
    echo "Aucun changement à déployer."
else
    COMMIT_MSG="Deploy PME-SmartTech- - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "[GIT] Commit : $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
fi

# === Étape 7 : Push vers GitHub ===
echo "[GIT] Envoi vers GitHub..."
git push -u origin "$BRANCH"

# === Étape 8 : Résultat final ===
echo ""
echo "================================================================"
echo "Déploiement PME-SmartTech- terminé avec succès."
echo "Dépôt GitHub : https://github.com/${GIT_USER}/${REPO_NAME}"
echo "Clé SSH utilisée : $(basename "$SSH_KEY_PATH")"
echo "Date : $(date)"
echo "================================================================"
