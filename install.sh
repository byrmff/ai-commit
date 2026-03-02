#!/usr/bin/env bash
set -euo pipefail

# ─── Config ──────────────────────────────────────────────────────────────────
REPO="byrmff/ai-commit"
BINARY="ai-commit"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/ai-commit"
CONFIG_FILE="$CONFIG_DIR/config"
VERSION="${1:-latest}"            # optional: pass version as arg

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[ai-commit]${NC} $*"; }
warn()    { echo -e "${YELLOW}[ai-commit]${NC} $*"; }
error()   { echo -e "${RED}[ai-commit]${NC} $*" >&2; exit 1; }

# ─── Root check ──────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    error "Run with sudo: curl -fsSL https://byrmff.github.io/ai-commit/install.sh | sudo bash"
fi

# ─── Deps check ──────────────────────────────────────────────────────────────
for cmd in curl git jq; do
    command -v "$cmd" &>/dev/null || error "Missing dependency: $cmd — install it first."
done

# ─── Resolve version ─────────────────────────────────────────────────────────
if [[ "$VERSION" == "latest" ]]; then
    info "Fetching latest release..."
    VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
        | grep '"tag_name"' | cut -d'"' -f4)
    [[ -z "$VERSION" ]] && error "Could not resolve latest version. Check: https://github.com/$REPO/releases"
fi

info "Installing ai-commit $VERSION..."

# ─── Download ─────────────────────────────────────────────────────────────────
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

DOWNLOAD_URL="https://raw.githubusercontent.com/$REPO/$VERSION/ai-commit"

curl -fsSL "$DOWNLOAD_URL" -o "$TMP" \
    || error "Download failed. Check version tag or network."

# ─── Install binary ──────────────────────────────────────────────────────────
chmod +x "$TMP"
mv "$TMP" "$INSTALL_DIR/$BINARY"
info "Installed to $INSTALL_DIR/$BINARY"

# ─── Create config (skip if exists) ──────────────────────────────────────────
if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" <<'EOF'
# ai-commit configuration
# Get your API key: https://console.anthropic.com
ANTHROPIC_API_KEY=""
CLAUDE_MODEL="claude-haiku-4-5-20251001"
MAX_TOKENS=256
EOF
    info "Config created at $CONFIG_FILE"
else
    warn "Config already exists at $CONFIG_FILE — skipped."
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}✅ ai-commit $VERSION installed successfully!${NC}"
echo ""
echo "  Next steps:"
echo "  1. Add your API key:  sudo nano $CONFIG_FILE"
echo "     Or per-user:       echo 'ANTHROPIC_API_KEY=\"sk-ant-...\"' > ~/.config/ai-commit/config"
echo "  2. Stage some files:  git add ."
echo "  3. Run:               ai-commit"
echo ""
