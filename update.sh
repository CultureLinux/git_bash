#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
REPO="CultureLinux/git_bash"
BASE_DIR="$HOME/.git_bash"
mkdir -p "$BASE_DIR"

RAW_URL="https://raw.githubusercontent.com/${REPO}/main"
INSTALL_SCRIPT_URL="${RAW_URL}/install.sh"
UPDATE_SCRIPT="$BASE_DIR/update.sh"
LOCAL_VERSION_FILE="$BASE_DIR/git_completion_version"

# === Récupération de la version locale ===
if [ -f "$LOCAL_VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE")
else
    LOCAL_VERSION="none"
fi

# === Mise à jour du script lui-même ===
SCRIPT_URL="${RAW_URL}/update.sh"
TMP_SCRIPT=$(mktemp)
wget -qO "$TMP_SCRIPT" "$SCRIPT_URL"
chmod +x "$TMP_SCRIPT"

if ! cmp -s "$TMP_SCRIPT" "$UPDATE_SCRIPT"; then
    echo "🔄 Nouvelle version du script update.sh détectée !"
    mv "$TMP_SCRIPT" "$UPDATE_SCRIPT"
    echo "✅ Script update.sh mis à jour."
else
    rm "$TMP_SCRIPT"
fi

# === Récupération de la dernière release GitHub ===
LATEST_VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -Po '"tag_name":\s*"\K[^"]+' || echo "unknown")

# === Vérification de mise à jour du repo ===
if [ "$LATEST_VERSION" != "unknown" ] && [ "$LATEST_VERSION" != "$LOCAL_VERSION" ]; then
    echo "🆕 Nouvelle version disponible : $LATEST_VERSION (actuelle : $LOCAL_VERSION)"
    read -p "⚙️  Veux-tu mettre à jour ? (y/n) " yn
    case $yn in
        [Yy]* )
            echo "🔧 Mise à jour en cours..."
            wget -qO- "$INSTALL_SCRIPT_URL" | bash
            echo "$LATEST_VERSION" > "$LOCAL_VERSION_FILE"
            echo "✅ Mise à jour terminée vers $LATEST_VERSION"
            ;;
        * )
            echo "❌ Mise à jour annulée."
            ;;
    esac
fi
