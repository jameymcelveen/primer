#!/bin/zsh
#
# Python Module - Python, venv, requirements.txt
#

: ${GREEN:='\033[0;32m'}
: ${YELLOW:='\033[1;33m'}
: ${DIM:='\033[2m'}
: ${NC:='\033[0m'}
: ${ICON_OK:="✓"}
: ${ICON_ARROW:="→"}

command_exists() {
    command -v "$1" &> /dev/null
}

# =============================================================================
# Checks & Installs
# =============================================================================

install_python() {
    if ! command_exists python3; then
        echo -e "    ${ICON_ARROW} Installing Python..."
        brew install python
    else
        local version=$(python3 --version)
        echo -e "    ${GREEN}${ICON_OK}${NC} Python installed ${DIM}($version)${NC}"
    fi
}

create_venv() {
    if [[ ! -d ".venv" ]]; then
        echo -e "    ${ICON_ARROW} Creating virtual environment..."
        python3 -m venv .venv
        echo -e "    ${DIM}Activate with: source .venv/bin/activate${NC}"
    else
        echo -e "    ${GREEN}${ICON_OK}${NC} Virtual environment exists"
    fi
}

create_requirements() {
    if [[ ! -f "requirements.txt" ]]; then
        echo -e "    ${ICON_ARROW} Creating requirements.txt..."
        touch requirements.txt
    fi
}

add_python_to_gitignore() {
    if [[ -f ".gitignore" ]] && ! grep -q ".venv" .gitignore 2>/dev/null; then
        echo -e "    ${ICON_ARROW} Adding Python files to .gitignore..."
        echo "" >> .gitignore
        echo "# Python" >> .gitignore
        echo ".venv/" >> .gitignore
        echo "__pycache__/" >> .gitignore
        echo "*.pyc" >> .gitignore
    fi
}

# =============================================================================
# Main
# =============================================================================

echo -e "    ${DIM}Setting up Python environment...${NC}"
install_python
create_venv
create_requirements
add_python_to_gitignore

echo -e "    ${GREEN}${ICON_OK}${NC} Python module complete"
