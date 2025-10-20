#!/usr/bin/env bash
set -euo pipefail

# Couleurs
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

# === CONFIG ===
BASE_DIR="$HOME/.git_bash"
mkdir -p "$BASE_DIR"

REPO="CultureLinux/git_bash"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main"
INSTALL_SCRIPT_URL="${RAW_URL}/install.sh"
LOCAL_VERSION_FILE="$BASE_DIR/git_completion_version"
UPDATE_SCRIPT="$BASE_DIR/update.sh"
GIT_COMPLETION="$BASE_DIR/git_completion"

echo -e "${GREEN}==> Installation ou mise à jour de l'autocomplétion Git...${NC}"

# Téléchargement du git_completion
TMP_FILE=$(mktemp)
wget -qO "$TMP_FILE" "${RAW_URL}/git_completion"
cp "$TMP_FILE" "$GIT_COMPLETION"
rm -f "$TMP_FILE"

# Détection du shell
if [ -n "${ZSH_VERSION-}" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "${BASH_VERSION-}" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo -e "${RED}Shell non supporté.${NC}"
    exit 1
fi

# Ajout du sourcing si absent
if ! grep -qxF "source $GIT_COMPLETION" "$SHELL_RC"; then
    echo "source $GIT_COMPLETION" >> "$SHELL_RC"
    echo -e "${GREEN}Ajout de 'source $GIT_COMPLETION' dans $SHELL_RC${NC}"
else
    echo -e "${GREEN}La ligne existe déjà dans $SHELL_RC${NC}"
fi

# Récupération de la dernière version publiée
LATEST_VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -Po '"tag_name":\s*"\K[^"]+' || echo "dev")

if [ -z "$LATEST_VERSION" ]; then
    LATEST_VERSION="dev"
fi

echo "$LATEST_VERSION" > "$LOCAL_VERSION_FILE"
echo -e "${GREEN}Version locale mise à jour : ${LATEST_VERSION}${NC}"

# --- Récupération du script d'auto-update ---
wget -qO "$UPDATE_SCRIPT" "${RAW_URL}/update.sh"
chmod +x "$UPDATE_SCRIPT"

# --- Ajout au shell RC ---
if ! grep -qxF "$UPDATE_SCRIPT" "$SHELL_RC"; then
    echo "$UPDATE_SCRIPT" >> "$SHELL_RC"
    echo -e "${GREEN}Ajout de la vérification de mise à jour à l'ouverture de session${NC}"
fi

echo -e "${GREEN}✅ Installation terminée ! Redémarre ton terminal pour activer l'autocomplétion.${NC}"
