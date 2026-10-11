#!/usr/bin/env bash
#
# agy-switch installer
# Multi-account switcher & real-time quota monitor for Google Antigravity (AGY)
#
set -euo pipefail

REPO="blackrain02/agy-switch"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/agy-switch"

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}==> Installing agy-switch...${NC}"

# Check Python 3
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}Error: python3 is required but not installed.${NC}" >&2
    exit 1
fi

# Determine target install directory
if [ -w "/usr/local/bin" ] && [ -n "${INSTALL_GLOBAL:-}" ]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "${INSTALL_DIR}"
fi

TARGET="${INSTALL_DIR}/agy-switch"

# If running from inside a cloned repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if [ -f "${SCRIPT_DIR}/agy-switch" ]; then
    echo "Copying agy-switch from local repository..."
    cp "${SCRIPT_DIR}/agy-switch" "${TARGET}"
else
    echo "Downloading agy-switch from GitHub (${REPO})..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${RAW_URL}" -o "${TARGET}"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "${TARGET}" "${RAW_URL}"
    else
        echo -e "${RED}Error: curl or wget is required to download.${NC}" >&2
        exit 1
    fi
fi

chmod +x "${TARGET}"

# Install guardian wrapper
echo "Installing transparent token & auto-login guard..."
"${TARGET}" --install-guard >/dev/null 2>&1 || true

echo -e "${GREEN}✓ Successfully installed agy-switch to ${TARGET}${NC}"

# Check if INSTALL_DIR is in PATH
case ":${PATH}:" in
    *":${INSTALL_DIR}:"*) ;;
    *)
        echo -e "${YELLOW}Notice: ${INSTALL_DIR} is not in your PATH.${NC}"
        echo "Add it to your shell configuration file (~/.bashrc, ~/.zshrc):"
        echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
        ;;
esac

echo ""
echo -e "${BOLD}Get started:${NC}"
echo "  agy-switch          # Launch interactive switch menu with live quotas"
echo "  agy-switch -s       # Save current logged-in account"
echo "  agy-switch -l       # View comparative quota table (Gemini + Claude/GPT)"
echo "  agy-switch --help   # View all commands"
echo ""
