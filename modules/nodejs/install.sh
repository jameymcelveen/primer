#!/bin/zsh
#
# Node.js Module - Node, npm, package.json setup
#

: ${GREEN:='\033[0;32m'}
: ${YELLOW:='\033[1;33m'}
: ${DIM:='\033[2m'}
: ${NC:='\033[0m'}
: ${ICON_OK:="✓"}
: ${ICON_MISSING:="✗"}
: ${ICON_ARROW:="→"}

NODE_VERSION="${SCAFFOLD_NODE_VERSION:-20}"

command_exists() {
    command -v "$1" &> /dev/null
}

# =============================================================================
# Checks
# =============================================================================

check_node() {
    if command_exists node; then
        local version=$(node --version)
        echo -e "    ${GREEN}${ICON_OK}${NC} Node.js installed ${DIM}($version)${NC}"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Node.js not installed"
        return 1
    fi
}

check_npm() {
    if command_exists npm; then
        local version=$(npm --version)
        echo -e "    ${GREEN}${ICON_OK}${NC} npm installed ${DIM}($version)${NC}"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} npm not installed"
        return 1
    fi
}

# =============================================================================
# Installs
# =============================================================================

install_node() {
    if ! command_exists node; then
        echo -e "    ${ICON_ARROW} Installing Node.js..."
        brew install node@$NODE_VERSION
        brew link node@$NODE_VERSION --force --overwrite 2>/dev/null || true
    fi
}

create_package_json() {
    if [[ ! -f "package.json" ]]; then
        echo -e "    ${ICON_ARROW} Creating package.json..."
        local project_name=$(basename "$PWD")
        cat > package.json << EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "lint": "echo \"No linter configured\""
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOF
    fi
}

add_node_to_gitignore() {
    if [[ -f ".gitignore" ]] && ! grep -q "node_modules" .gitignore 2>/dev/null; then
        echo -e "    ${ICON_ARROW} Adding node_modules to .gitignore..."
        echo "" >> .gitignore
        echo "# Node" >> .gitignore
        echo "node_modules/" >> .gitignore
        echo "npm-debug.log*" >> .gitignore
    fi
}

# =============================================================================
# Main
# =============================================================================

echo -e "    ${DIM}Checking Node.js requirements...${NC}"
check_node
check_npm

echo -e "    ${DIM}Installing Node.js...${NC}"
install_node
create_package_json
add_node_to_gitignore

echo -e "    ${GREEN}${ICON_OK}${NC} Node.js module complete"
