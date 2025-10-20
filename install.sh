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
echo -e "${GREEN}Installation terminée ! Redémarre ton terminal pour activer l'autocomplétion avec `. ~/.git_completion` ${NC}"
