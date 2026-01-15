#!/bin/zsh
#
# Godot Mono Module - Godot 4 with .NET/C# support
#

# =============================================================================
# Colors (inherit from parent or define)
# =============================================================================
: ${RED:='\033[0;31m'}
: ${GREEN:='\033[0;32m'}
: ${YELLOW:='\033[1;33m'}
: ${CYAN:='\033[0;36m'}
: ${DIM:='\033[2m'}
: ${NC:='\033[0m'}
: ${ICON_OK:="✓"}
: ${ICON_MISSING:="✗"}
: ${ICON_ARROW:="→"}

GODOT_MIN_VERSION="4.2"

# =============================================================================
# Utility Functions
# =============================================================================

command_exists() {
    command -v "$1" &> /dev/null
}

cask_installed() {
    brew list --cask "$1" &> /dev/null 2>&1
}

version_gte() {
    local v1="$1"
    local v2="$2"
    if [[ "$(printf '%s\n' "$v2" "$v1" | sort -V | head -n1)" == "$v2" ]]; then
        return 0
    else
        return 1
    fi
}

get_godot_version() {
    local version=""
    if [[ -d "/Applications/Godot_mono.app" ]]; then
        version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "/Applications/Godot_mono.app/Contents/Info.plist" 2>/dev/null || echo "")
    fi
    echo "$version"
}

# =============================================================================
# Checks
# =============================================================================

check_godot_mono() {
    if cask_installed godot-mono; then
        local version=$(get_godot_version)
        echo -e "    ${GREEN}${ICON_OK}${NC} Godot Mono installed ${DIM}($version)${NC}"
        return 0
    elif [[ -d "/Applications/Godot_mono.app" ]]; then
        local version=$(get_godot_version)
        echo -e "    ${GREEN}${ICON_OK}${NC} Godot Mono installed ${DIM}($version)${NC}"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Godot Mono not installed"
        return 1
    fi
}

check_dotnet() {
    if command_exists dotnet; then
        local version=$(dotnet --version 2>/dev/null)
        echo -e "    ${GREEN}${ICON_OK}${NC} .NET SDK installed ${DIM}($version)${NC}"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} .NET SDK not installed"
        return 1
    fi
}

check_wrong_godot() {
    # Check if standard Godot (no C#) is installed
    if cask_installed godot || [[ -d "/Applications/Godot.app" && ! -d "/Applications/Godot_mono.app" ]]; then
        echo -e "    ${YELLOW}${ICON_ARROW}${NC} Standard Godot found (no C# support) — will replace"
        return 1
    fi
    return 0
}

# =============================================================================
# Installs
# =============================================================================

install_dotnet() {
    if ! command_exists dotnet; then
        echo -e "    ${ICON_ARROW} Installing .NET SDK..."
        brew install dotnet
    fi
}

install_godot_mono() {
    local needs_install=false
    
    # Check if wrong version is installed
    if cask_installed godot; then
        echo -e "    ${ICON_ARROW} Removing standard Godot (no C# support)..."
        brew uninstall --cask godot 2>/dev/null || true
        needs_install=true
    fi
    
    if [[ -d "/Applications/Godot.app" && ! -d "/Applications/Godot_mono.app" ]]; then
        echo -e "    ${ICON_ARROW} Removing /Applications/Godot.app..."
        rm -rf "/Applications/Godot.app" 2>/dev/null || true
        needs_install=true
    fi
    
    if ! cask_installed godot-mono && ! [[ -d "/Applications/Godot_mono.app" ]]; then
        needs_install=true
    fi
    
    if [[ "$needs_install" == "true" ]]; then
        echo -e "    ${ICON_ARROW} Installing Godot Mono (with C# support)..."
        brew install --cask godot-mono
    fi
}

create_godot_makefile_targets() {
    # Append Godot targets to Makefile if they don't exist
    if [[ -f "Makefile" ]] && ! grep -q "godot" Makefile 2>/dev/null; then
        echo -e "    ${ICON_ARROW} Adding Godot targets to Makefile..."
        cat >> Makefile << 'EOF'

# Godot targets
GODOT_MONO := /Applications/Godot_mono.app/Contents/MacOS/Godot
PROJECT_PATH := $(CURDIR)/game

open:
	@echo "Opening in Godot..."
	@open -a "Godot_mono" "$(PROJECT_PATH)/project.godot" 2>/dev/null || \
		$(GODOT_MONO) --editor --path "$(PROJECT_PATH)" &

run:
	@echo "Running game..."
	@$(GODOT_MONO) --path "$(PROJECT_PATH)"

build:
	@echo "Building C# project..."
	@cd $(PROJECT_PATH) && dotnet build
EOF
    fi
}

# =============================================================================
# Main
# =============================================================================

echo -e "    ${DIM}Checking Godot Mono requirements...${NC}"
check_dotnet
check_wrong_godot
check_godot_mono

echo -e "    ${DIM}Installing Godot Mono...${NC}"
install_dotnet
install_godot_mono
create_godot_makefile_targets

echo -e "    ${GREEN}${ICON_OK}${NC} Godot Mono module complete"
echo -e "    ${DIM}Note: Use Godot_mono.app for C# projects${NC}"
