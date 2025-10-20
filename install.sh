#!/usr/bin/env bash
set -euo pipefail

# Couleurs
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

REPO="CultureLinux/git_bash"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/${REPO}/main/install.sh"
LOCAL_VERSION_FILE="$HOME/.git_completion_version"
UPDATE_SCRIPT="$HOME/.git_completion_update.sh"

echo -e "${GREEN}==> Installation ou mise à jour de l'autocomplétion Git...${NC}"

# Téléchargement du .git_completion
TMP_FILE=$(mktemp)
wget -qO "$TMP_FILE" "${RAW_URL}/.git_completion"
cp "$TMP_FILE" ~/.git_completion
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
if ! grep -qxF "source ~/.git_completion" "$SHELL_RC"; then
    echo "source ~/.git_completion" >> "$SHELL_RC"
    echo -e "${GREEN}Ajout de 'source ~/.git_completion' dans $SHELL_RC${NC}"
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

# --- Création du script d'auto-update ---
cat > "$UPDATE_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO}"
RAW_URL="https://raw.githubusercontent.com/\${REPO}/main"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/\${REPO}/main/install.sh"
LOCAL_VERSION_FILE="\$HOME/.git_completion_version"

# Récupère la version locale
if [ -f "\$LOCAL_VERSION_FILE" ]; then
    LOCAL_VERSION=\$(cat "\$LOCAL_VERSION_FILE")
else
    LOCAL_VERSION="none"
fi

# Récupère la dernière release GitHub
LATEST_VERSION=\$(curl -fsSL "https://api.github.com/repos/\${REPO}/releases/latest" \
    | grep -Po '"tag_name":\\s*"\K[^"]+' || echo "unknown")

# Si nouvelle version → met à jour automatiquement
if [ "\$LATEST_VERSION" != "unknown" ] && [ "\$LATEST_VERSION" != "\$LOCAL_VERSION" ]; then
    echo "🆕 Nouvelle version détectée : \$LATEST_VERSION (actuelle : \$LOCAL_VERSION)"
    echo "⚙️  Mise à jour en cours..."
    wget -qO- "\$INSTALL_SCRIPT_URL" | bash
    echo "\$LATEST_VERSION" > "\$LOCAL_VERSION_FILE"
    echo "✅ Mise à jour terminée vers \$LATEST_VERSION"
fi
EOF

chmod +x "$UPDATE_SCRIPT"

# --- Ajout au shell RC ---
if ! grep -qxF "$UPDATE_SCRIPT" "$SHELL_RC"; then
    echo "$UPDATE_SCRIPT" >> "$SHELL_RC"
    echo -e "${GREEN}Ajout de la vérification de mise à jour à l'ouverture de session${NC}"
fi

echo -e "${GREEN}✅ Installation terminée ! Redémarre ton terminal pour activer l'autocomplétion.${NC}"
