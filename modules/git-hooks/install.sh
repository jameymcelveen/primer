#!/bin/zsh
#
# Git Hooks Module - Pre-commit hooks, branch protection
#

: ${GREEN:='\033[0;32m'}
: ${YELLOW:='\033[1;33m'}
: ${DIM:='\033[2m'}
: ${NC:='\033[0m'}
: ${ICON_OK:="✓"}
: ${ICON_ARROW:="→"}

PROTECTED_BRANCH="${SCAFFOLD_PROTECT_BRANCH:-main}"

# =============================================================================
# Pre-commit Hook
# =============================================================================

install_pre_commit_hook() {
    local hooks_dir=".git/hooks"
    
    if [[ ! -d ".git" ]]; then
        echo -e "    ${YELLOW}Not a git repo, skipping hooks${NC}"
        return
    fi
    
    mkdir -p "$hooks_dir"
    
    if [[ ! -f "$hooks_dir/pre-commit" ]]; then
        echo -e "    ${ICON_ARROW} Creating pre-commit hook..."
        cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/zsh
# Pre-commit hook

echo "Running pre-commit checks..."

# Check for debug statements
if git diff --cached --name-only | xargs grep -l "console.log\|debugger\|binding.pry\|import pdb" 2>/dev/null; then
    echo "Warning: Debug statements found"
fi

# Run linter if available
if [[ -f "package.json" ]] && command -v npm &> /dev/null; then
    npm run lint --if-present
fi

exit 0
EOF
        chmod +x "$hooks_dir/pre-commit"
    fi
}

# =============================================================================
# Pre-push Hook (Protect Main)
# =============================================================================

install_pre_push_hook() {
    local hooks_dir=".git/hooks"
    
    if [[ ! -d ".git" ]]; then
        return
    fi
    
    mkdir -p "$hooks_dir"
    
    if [[ ! -f "$hooks_dir/pre-push" ]]; then
        echo -e "    ${ICON_ARROW} Creating pre-push hook (protects $PROTECTED_BRANCH)..."
        cat > "$hooks_dir/pre-push" << EOF
#!/bin/zsh
# Pre-push hook - Protect main branch

PROTECTED_BRANCH="$PROTECTED_BRANCH"
CURRENT_BRANCH=\$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [[ "\$CURRENT_BRANCH" == "\$PROTECTED_BRANCH" ]]; then
    echo ""
    echo "⚠️  Direct push to '\$PROTECTED_BRANCH' is not allowed!"
    echo "   Please create a branch and open a pull request."
    echo ""
    exit 1
fi

exit 0
EOF
        chmod +x "$hooks_dir/pre-push"
    fi
}

# =============================================================================
# GitHub Templates
# =============================================================================

install_github_templates() {
    if [[ ! -d ".github" ]]; then
        echo -e "    ${ICON_ARROW} Creating .github/ directory..."
        mkdir -p .github
    fi
    
    # Pull request template
    if [[ ! -f ".github/pull_request_template.md" ]]; then
        echo -e "    ${ICON_ARROW} Creating PR template..."
        cat > ".github/pull_request_template.md" << 'EOF'
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Code follows project style
- [ ] Tests added/updated
- [ ] Documentation updated
EOF
    fi
    
    # Issue templates directory
    mkdir -p ".github/ISSUE_TEMPLATE"
    
    if [[ ! -f ".github/ISSUE_TEMPLATE/bug_report.md" ]]; then
        echo -e "    ${ICON_ARROW} Creating bug report template..."
        cat > ".github/ISSUE_TEMPLATE/bug_report.md" << 'EOF'
---
name: Bug Report
about: Report a bug
title: '[BUG] '
labels: bug
---

## Description
A clear description of the bug.

## Steps to Reproduce
1. 
2. 
3. 

## Expected Behavior


## Actual Behavior


## Environment
- OS: 
- Version: 
EOF
    fi
}

# =============================================================================
# Main
# =============================================================================

echo -e "    ${DIM}Setting up git hooks...${NC}"
install_pre_commit_hook
install_pre_push_hook
install_github_templates

echo -e "    ${GREEN}${ICON_OK}${NC} Git hooks module complete"
echo -e "    ${DIM}Protected branch: $PROTECTED_BRANCH${NC}"
