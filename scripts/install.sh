#!/bin/bash
#
# Primer CLI Installer
#
# Usage:
#   curl -fsSL https://primer.dev/install.sh | bash
#   curl -fsSL https://primer.dev/install.sh | bash -s -- --version 0.1.0
#
# This script:
#   1. Detects if npm is available
#   2. Installs primer globally via npm, or
#   3. Falls back to cloning the repo and linking
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Config
REPO_URL="https://github.com/jameymcelveen/primer.git"
NPM_PACKAGE="@primer-bootstrap/cli"
INSTALL_DIR="${PRIMER_INSTALL_DIR:-$HOME/.primer}"
VERSION="${1:-latest}"

# Helpers
info() {
  echo -e "${BLUE}info${NC} $1"
}

success() {
  echo -e "${GREEN}✓${NC} $1"
}

warn() {
  echo -e "${YELLOW}warn${NC} $1"
}

error() {
  echo -e "${RED}error${NC} $1"
  exit 1
}

header() {
  echo ""
  echo -e "${BOLD}══════════════════════════════════════════${NC}"
  echo -e "${BOLD}  🎨 Primer CLI Installer${NC}"
  echo -e "${BOLD}══════════════════════════════════════════${NC}"
  echo ""
}

# Check for required commands
check_requirements() {
  if ! command -v node &> /dev/null; then
    error "Node.js is required but not installed. Install it from https://nodejs.org"
  fi

  NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -lt 18 ]; then
    error "Node.js 18+ is required. Current version: $(node -v)"
  fi

  success "Node.js $(node -v) detected"
}

# Install via npm (preferred)
install_via_npm() {
  info "Installing via npm..."
  
  if [ "$VERSION" = "latest" ]; then
    npm install -g "$NPM_PACKAGE"
  else
    npm install -g "$NPM_PACKAGE@$VERSION"
  fi

  success "Installed primer via npm"
}

# Install via git clone (fallback)
install_via_git() {
  info "Installing via git..."

  if ! command -v git &> /dev/null; then
    error "Git is required for this installation method"
  fi

  # Clone or update
  if [ -d "$INSTALL_DIR" ]; then
    info "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin main
  else
    info "Cloning primer..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
  fi

  # Install dependencies
  info "Installing dependencies..."
  npm install

  # Link globally
  info "Linking globally..."
  npm link

  success "Installed primer via git"
}

# Add to PATH if needed
setup_path() {
  local shell_rc=""
  
  case "$SHELL" in
    */zsh)
      shell_rc="$HOME/.zshrc"
      ;;
    */bash)
      shell_rc="$HOME/.bashrc"
      ;;
    *)
      shell_rc="$HOME/.profile"
      ;;
  esac

  # Check if primer is in PATH
  if command -v primer &> /dev/null; then
    return 0
  fi

  # Add npm global bin to PATH if not present
  local npm_bin="$(npm config get prefix)/bin"
  if [[ ":$PATH:" != *":$npm_bin:"* ]]; then
    echo "" >> "$shell_rc"
    echo "# Primer CLI" >> "$shell_rc"
    echo "export PATH=\"\$PATH:$npm_bin\"" >> "$shell_rc"
    warn "Added npm bin to PATH in $shell_rc"
    warn "Run 'source $shell_rc' or restart your terminal"
  fi
}

# Verify installation
verify_install() {
  if command -v primer &> /dev/null; then
    success "primer $(primer --version) installed successfully!"
    echo ""
    echo -e "  ${CYAN}Get started:${NC}"
    echo "    primer init        # Initialize a new project"
    echo "    primer list        # List available modules"
    echo "    primer --help      # Show help"
    echo ""
  else
    warn "primer installed but not in PATH yet"
    warn "Restart your terminal or run: source ~/.zshrc"
  fi
}

# Main
main() {
  header
  check_requirements

  # Try npm first
  if command -v npm &> /dev/null; then
    # Check if package is published
    if npm view "$NPM_PACKAGE" version &> /dev/null 2>&1; then
      install_via_npm
    else
      info "npm package not yet published, using git installation..."
      install_via_git
    fi
  else
    install_via_git
  fi

  setup_path
  verify_install
}

main "$@"
