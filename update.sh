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

# === FONCTIONS ===
error_exit() {
    echo "❌ ERREUR : $1" >&2
    exit 1
}

info() { echo "ℹ️  $1"; }
success() { echo "✅ $1"; }
warn() { echo "⚠️  $1"; }

# === RÉCUPÉRATION DE LA VERSION LOCALE ===
if [ -f "$LOCAL_VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE")
else
    LOCAL_VERSION="none"
fi

# === MISE À JOUR DU SCRIPT update.sh ===
SCRIPT_URL="${RAW_URL}/update.sh"
TMP_SCRIPT=$(mktemp)

info "Téléchargement du dernier update.sh..."
if ! wget -qO "$TMP_SCRIPT" "$SCRIPT_URL"; then
    error_exit "Impossible de télécharger update.sh depuis $SCRIPT_URL"
fi
chmod +x "$TMP_SCRIPT"

if ! cmp -s "$TMP_SCRIPT" "$UPDATE_SCRIPT"; then
    warn "Nouvelle version du script update.sh détectée."
    mv "$TMP_SCRIPT" "$UPDATE_SCRIPT"
    success "Script update.sh mis à jour."
else
    rm -f "$TMP_SCRIPT"
    info "Script update.sh déjà à jour."
fi

# === RÉCUPÉRATION DE LA DERNIÈRE RELEASE ===
info "Récupération de la dernière release GitHub..."

CURL_OPTS=(
    --fail
    --silent
    --show-error
    --max-time 10
    -H "Accept: application/vnd.github+json"
    -H "User-Agent: git-bash-updater"
)

if [ -n "${GITHUB_TOKEN:-}" ]; then
    CURL_OPTS+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

LATEST_VERSION=$(curl "${CURL_OPTS[@]}" "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -Po '"tag_name":\s*"\K[^"]+' || true)

if [ -z "$LATEST_VERSION" ]; then
    error_exit "Impossible de récupérer la version distante sur GitHub."
fi

# === COMPARAISON ===
if [ "$LATEST_VERSION" != "$LOCAL_VERSION" ]; then
    echo "🆕 Nouvelle version disponible : $LATEST_VERSION (actuelle : $LOCAL_VERSION)"
    read -r -p "⚙️  Veux-tu mettre à jour ? (y/n) " yn
    case $yn in
        [Yy]* )
            info "Mise à jour en cours..."
            if ! wget -qO- "$INSTALL_SCRIPT_URL" | bash; then
                error_exit "Échec de l’exécution du script d’installation."
            fi
            echo "$LATEST_VERSION" > "$LOCAL_VERSION_FILE"
            success "Mise à jour terminée vers $LATEST_VERSION"
            ;;
        * )
            warn "Mise à jour annulée."
            ;;
    esac
else
    success "Aucune mise à jour disponible. Version actuelle : $LOCAL_VERSION"
fi
