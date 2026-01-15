#!/bin/zsh
#
# Primer - Composable Project Bootstrapper
# 
# Usage:
#   ./init.sh primer.yaml        # Run with config file
#   ./init.sh --interactive      # Interactive module selection
#   ./init.sh --list             # List available modules
#

set -o NO_ERR_EXIT 2>/dev/null || true

SCRIPT_DIR="${0:A:h}"
MODULES_DIR="$SCRIPT_DIR/modules"

# =============================================================================
# Colors & Formatting
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ICON_OK="✓"
ICON_MISSING="✗"
ICON_UPDATE="↑"
ICON_ARROW="→"

# =============================================================================
# Utility Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BOLD}══════════════════════════════════════════${NC}"
    echo -e "${BOLD}  🎨 Primer - Project Bootstrapper${NC}"
    echo -e "${BOLD}══════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${DIM}─────────────────────────────────────────${NC}"
}

list_modules() {
    print_section "Available Modules"
    echo ""
    for module_dir in "$MODULES_DIR"/*/; do
        if [[ -d "$module_dir" ]]; then
            local module_name=$(basename "$module_dir")
            local desc_file="$module_dir/description.txt"
            local desc=""
            if [[ -f "$desc_file" ]]; then
                desc=$(cat "$desc_file")
            fi
            printf "  ${CYAN}%-15s${NC} %s\n" "$module_name" "$desc"
        fi
    done
    echo ""
}

# =============================================================================
# YAML Parser (Simple)
# =============================================================================

parse_modules_from_yaml() {
    local yaml_file="$1"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo ""
        return 1
    fi
    
    # Extract modules list (simple grep-based parsing)
    grep -A 100 "^modules:" "$yaml_file" 2>/dev/null | \
        grep "^  -" | \
        sed 's/^  - //' | \
        tr '\n' ' '
}

parse_project_name() {
    local yaml_file="$1"
    grep "^name:" "$yaml_file" 2>/dev/null | sed 's/name: *//'
}

# =============================================================================
# Interactive Mode
# =============================================================================

interactive_select() {
    print_section "Select Modules"
    echo ""
    echo "  Enter module numbers separated by spaces (e.g., 1 3 5)"
    echo "  Or 'all' for everything, 'q' to quit"
    echo ""
    
    local modules=()
    local i=1
    
    for module_dir in "$MODULES_DIR"/*/; do
        if [[ -d "$module_dir" ]]; then
            local module_name=$(basename "$module_dir")
            modules+=("$module_name")
            printf "  ${CYAN}%2d)${NC} %s\n" "$i" "$module_name"
            ((i++))
        fi
    done
    
    echo ""
    printf "  Selection: "
    read selection
    
    if [[ "$selection" == "q" ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    if [[ "$selection" == "all" ]]; then
        echo "${modules[@]}"
        return
    fi
    
    local selected=()
    for num in ${=selection}; do
        if [[ $num -ge 1 && $num -le ${#modules[@]} ]]; then
            selected+=("${modules[$num]}")
        fi
    done
    
    echo "${selected[@]}"
}

# =============================================================================
# Module Runner
# =============================================================================

run_module() {
    local module_name="$1"
    local module_script="$MODULES_DIR/$module_name/install.sh"
    
    if [[ ! -f "$module_script" ]]; then
        echo -e "  ${RED}${ICON_MISSING}${NC} Module not found: $module_name"
        return 1
    fi
    
    echo -e "  ${ICON_ARROW} Running module: ${CYAN}$module_name${NC}"
    
    # Source the module script
    source "$module_script"
    
    echo -e "  ${GREEN}${ICON_OK}${NC} Completed: $module_name"
}

run_modules() {
    local modules=("$@")
    
    print_section "Running Modules"
    echo ""
    
    for module in "${modules[@]}"; do
        run_module "$module"
    done
    
    echo ""
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    print_header
    
    local config_file=""
    local modules=()
    
    # Parse arguments
    case "$1" in
        --interactive|-i)
            modules=($(interactive_select))
            ;;
        --list|-l)
            list_modules
            exit 0
            ;;
        --help|-h)
            echo "Usage:"
            echo "  ./init.sh primer.yaml      # Run with config file"
            echo "  ./init.sh --interactive    # Interactive module selection"
            echo "  ./init.sh --list           # List available modules"
            exit 0
            ;;
        "")
            # Check for default config files
            if [[ -f "primer.yaml" ]]; then
                config_file="primer.yaml"
            elif [[ -f "primer.yml" ]]; then
                config_file="primer.yml"
            else
                echo "No config file found. Use --interactive or provide a config file."
                echo "Run ./init.sh --help for usage."
                exit 1
            fi
            ;;
        *)
            config_file="$1"
            ;;
    esac
    
    # Parse config file if provided
    if [[ -n "$config_file" ]]; then
        if [[ ! -f "$config_file" ]]; then
            echo -e "${RED}Config file not found: $config_file${NC}"
            exit 1
        fi
        
        local project_name=$(parse_project_name "$config_file")
        echo -e "Project: ${CYAN}$project_name${NC}"
        echo -e "Config:  ${DIM}$config_file${NC}"
        
        modules=($(parse_modules_from_yaml "$config_file"))
    fi
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No modules selected.${NC}"
        exit 0
    fi
    
    echo -e "Modules: ${modules[*]}"
    
    # Run the modules
    run_modules "${modules[@]}"
    
    print_section "Complete!"
    echo ""
    echo -e "  ${GREEN}${ICON_OK}${NC} Project primed successfully"
    echo ""
}

main "$@"
