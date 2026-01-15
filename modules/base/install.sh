#!/bin/zsh
#
# Base Module - Git, Homebrew, GitHub CLI, Makefile, .github/
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

# =============================================================================
# Utility Functions
# =============================================================================

command_exists() {
    command -v "$1" &> /dev/null
}

brew_installed() {
    brew list "$1" &> /dev/null 2>&1
}

# =============================================================================
# Checks
# =============================================================================

check_homebrew() {
    if command_exists brew; then
        echo -e "    ${GREEN}${ICON_OK}${NC} Homebrew installed"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Homebrew not installed"
        return 1
    fi
}

check_git() {
    if command_exists git; then
        echo -e "    ${GREEN}${ICON_OK}${NC} Git installed"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Git not installed"
        return 1
    fi
}

check_gh() {
    if command_exists gh; then
        echo -e "    ${GREEN}${ICON_OK}${NC} GitHub CLI installed"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} GitHub CLI not installed"
        return 1
    fi
}

check_git_aliases() {
    local missing=0
    local aliases=("co" "br" "ci" "st" "lg" "ll" "undo" "amend")
    
    for a in "${aliases[@]}"; do
        if ! git config --global --get "alias.$a" &> /dev/null; then
            missing=$((missing + 1))
        fi
    done
    
    if [[ $missing -eq 0 ]]; then
        echo -e "    ${GREEN}${ICON_OK}${NC} Git aliases configured"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Git aliases missing ($missing/${#aliases[@]})"
        return 1
    fi
}

# =============================================================================
# Installs
# =============================================================================

install_homebrew() {
    if ! command_exists brew; then
        echo -e "    ${ICON_ARROW} Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

install_git() {
    if ! command_exists git; then
        echo -e "    ${ICON_ARROW} Installing Git..."
        brew install git
    fi
}

install_gh() {
    if ! command_exists gh; then
        echo -e "    ${ICON_ARROW} Installing GitHub CLI..."
        brew install gh
    fi
}

install_git_aliases() {
    echo -e "    ${ICON_ARROW} Configuring Git aliases..."
    
    git config --global alias.co "checkout" 2>/dev/null || true
    git config --global alias.br "branch" 2>/dev/null || true
    git config --global alias.ci "commit" 2>/dev/null || true
    git config --global alias.st "status" 2>/dev/null || true
    git config --global alias.unstage "reset HEAD --" 2>/dev/null || true
    git config --global alias.last "log -1 HEAD" 2>/dev/null || true
    git config --global alias.lg "log --oneline --graph --decorate --all" 2>/dev/null || true
    git config --global alias.ll "log --pretty=format:'%C(yellow)%h%Creset %s %C(cyan)(%cr)%Creset %C(green)<%an>%Creset' --abbrev-commit" 2>/dev/null || true
    git config --global alias.undo "reset --soft HEAD~1" 2>/dev/null || true
    git config --global alias.amend "commit --amend --no-edit" 2>/dev/null || true
    git config --global alias.wip '!git add -A && git commit -m "WIP"' 2>/dev/null || true
    git config --global alias.fresh "!git fetch --all --prune && git pull" 2>/dev/null || true
    
    # Git config
    git config --global init.defaultBranch main 2>/dev/null || true
    git config --global pull.rebase true 2>/dev/null || true
    git config --global push.autoSetupRemote true 2>/dev/null || true
}

install_makefile() {
    if [[ ! -f "Makefile" ]]; then
        echo -e "    ${ICON_ARROW} Creating Makefile..."
        cat > Makefile << 'EOF'
.PHONY: help install

help:
	@echo "Available commands:"
	@echo "  make install  - Install dependencies"
	@echo "  make help     - Show this help"

install:
	@echo "Running install..."
	@./scripts/install.sh
EOF
    fi
}

install_gitignore() {
    if [[ ! -f ".gitignore" ]]; then
        echo -e "    ${ICON_ARROW} Creating .gitignore..."
        cat > .gitignore << 'EOF'
# OS
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Build
/build/
/dist/
/bin/
/obj/

# Dependencies
/node_modules/
/.venv/
__pycache__/

# Logs
*.log
npm-debug.log*

# Environment
.env
.env.local
EOF
    fi
}

# =============================================================================
# Main
# =============================================================================

echo -e "    ${DIM}Checking base tools...${NC}"
check_homebrew
check_git
check_gh
check_git_aliases

echo -e "    ${DIM}Installing base tools...${NC}"
install_homebrew
install_git
install_gh
install_git_aliases
install_makefile
install_gitignore

echo -e "    ${GREEN}${ICON_OK}${NC} Base module complete"
