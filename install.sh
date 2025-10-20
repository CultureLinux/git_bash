#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${GREEN}==> Installation de l'autocomplétion Git et des alias...${NC}"

TMP_FILE=$(mktemp)
wget -qO "$TMP_FILE" "https://raw.githubusercontent.com/CultureLinux/git_bash/develop/.git_completion"

# Copie vers le home
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

# Recharge du shell
# On ne source pas ici pour éviter les comportements étranges via pipe bash
echo -e "${GREEN}Installation terminée ! Redémarre ton terminal pour activer l'autocomplétion. ${NC}"

echo -e "${GREEN}Création de l'autoupdate ${NC}"

# Création du script de vérification automatique
cat > ~/.git_completion_update.sh <<'EOF'
#!/usr/bin/env bash

REPO="CultureLinux/git_bash"
LOCAL_VERSION_FILE="$HOME/.git_completion_version"

# Récupère la version locale (ou vide)
if [ -f "$LOCAL_VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE")
else
    LOCAL_VERSION="none"
fi

# Récupère la dernière release via GitHub API
LATEST_VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -Po '"tag_name":\s*"\K[^"]+' || echo "unknown")

# Compare et avertit si nouvelle version
if [ "$LATEST_VERSION" != "unknown" ] && [ "$LATEST_VERSION" != "$LOCAL_VERSION" ]; then
    echo "🆕 Nouvelle version de git-completion dispo : ${LATEST_VERSION} (actuelle : ${LOCAL_VERSION})"
    echo "👉 Mets à jour avec : wget -qO- https://raw.githubusercontent.com/${REPO}/main/scripts/install.sh | bash"
fi
EOF

chmod +x ~/.git_completion_update.sh

echo -e "${GREEN}Ajout de l'auto-update  ${NC}"

# Vérification automatique à l'ouverture de session
if ! grep -qxF "~/.git_completion_update.sh" "$SHELL_RC"; then
    echo "~/.git_completion_update.sh" >> "$SHELL_RC"
    echo -e "${GREEN}Ajout de la vérification de mise à jour à l'ouverture de session${NC}"
fi

# Écrit la version actuelle (si tag ou défaut)
CURRENT_VERSION=$(curl -fsSL "https://api.github.com/repos/CultureLinux/git_bash/releases/latest" \
    | grep -Po '"tag_name":\s*"\K[^"]+' || echo "dev")
echo "$CURRENT_VERSION" > ~/.git_completion_version

