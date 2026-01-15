# Primer - Composable Project Bootstrapper

> A modular, idempotent project bootstrapping system.
> Last updated: January 15, 2026

---

## Overview

Primer is a CLI tool for bootstrapping new projects with reusable, composable modules. Think of it like Docker Compose for project setup — you define what you need in a config file, and it installs/configures everything idempotently.

## Key Principles

1. **Composable** — Modules are independent and can be combined
2. **Declarative** — Define what you need in `primer.yaml`
3. **Idempotent** — Safe to run multiple times; only installs what's missing
4. **Interactive** — `primer init` wizard like npm init
5. **Extensible** — Easy to add new modules
6. **Cross-Platform** — Node.js CLI works on macOS, Linux, and Windows (coming soon)

## Architecture

### CLI (Node.js)

```
primer/
├── bin/
│   └── primer.js              # CLI entry point
├── src/
│   ├── commands/
│   │   ├── init.js            # primer init (interactive wizard)
│   │   ├── add.js             # primer add <module>
│   │   ├── list.js            # primer list
│   │   └── run.js             # primer run
│   ├── core/
│   │   ├── config.js          # YAML config handling
│   │   └── module-runner.js   # Executes module scripts
│   └── utils/
│       ├── ui.js              # Colors, icons, formatting
│       └── prompts.js         # Interactive prompts
├── modules/                   # Shell install scripts (Unix)
├── modules-win/               # PowerShell scripts (Windows) — planned
├── scripts/
│   ├── install.sh             # curl installer
│   └── install.ps1            # PowerShell installer
├── Formula/
│   └── primer.rb              # Homebrew formula
└── package.json
```

### Commands

| Command | Description |
|---------|-------------|
| `primer init` | Interactive project setup (like npm init) |
| `primer init --yes` | Quick setup with defaults |
| `primer add <module>` | Add modules to existing project |
| `primer list` | List available modules |
| `primer run` | Run modules from primer.yaml |

## Installation

### npm (recommended)
```bash
npm install -g @primer-bootstrap/cli
```

### curl (macOS/Linux)
```bash
curl -fsSL https://primer.dev/install.sh | bash
```

### PowerShell (Windows)
```powershell
irm https://primer.dev/install.ps1 | iex
```

### Homebrew (macOS)
```bash
brew tap jameymcelveen/primer
brew install primer
```

## Modules

| Module | Description |
|--------|-------------|
| `base` | Git, Homebrew, GitHub CLI, Makefile, .gitignore |
| `godot-mono` | Godot 4 with .NET/C# support |
| `nodejs` | Node.js, npm, package.json |
| `python` | Python, venv, requirements.txt |
| `mobile` | iOS/Android export preparation |
| `git-hooks` | Pre-commit hooks, branch protection |
| `docker` | Dockerfile, docker-compose.yml |

## Config Format

```yaml
name: my-project
description: My awesome project

modules:
  - base
  - nodejs
  - git-hooks

options:
  nodejs:
    version: "20"
  git-hooks:
    protect-branch: main
```

## Development

### Adding a New Module

1. Create `modules/your-module/install.sh`
2. Add `modules/your-module/description.txt`
3. Follow the idempotent pattern:
   - Check current state
   - Install only if needed
   - Verify final state

### Module Template

```bash
#!/bin/zsh
# modules/your-module/install.sh

check_your_module() {
    # Return installed/missing/partial
}

install_your_module() {
    # Idempotent install logic
}

# Main
check_your_module
install_your_module
```

### Local Development

```bash
# Clone the repo
git clone https://github.com/jameymcelveen/primer.git
cd primer

# Install dependencies
npm install

# Link globally for testing
npm link

# Now you can use `primer` command anywhere
primer --version
```

---

## Progress

### Core
- [x] Architecture design
- [x] Shell-based init.sh (legacy)
- [x] Node.js CLI rewrite
- [x] `primer init` command
- [x] `primer add` command
- [x] `primer list` command
- [x] `primer run` command
- [x] Interactive prompts (inquirer)
- [x] Config file management (YAML)
- [x] Module runner (Unix)

### Distribution
- [x] npm package setup
- [x] curl installer script
- [x] PowerShell installer script
- [x] Homebrew formula (template)
- [ ] Publish to npm
- [ ] GitHub releases with binaries
- [ ] Homebrew tap

### Modules
- [x] Base module (git, makefile, github)
- [x] Godot-mono module
- [x] Node.js module
- [x] Python module
- [x] Mobile module
- [x] Git-hooks module
- [x] Docker module

### Future
- [ ] Windows PowerShell modules (modules-win/)
- [ ] Template variable substitution in configs
- [ ] `gum` or `fzf` integration for prettier menus
- [ ] Remote module registry
- [ ] Module dependencies

---

## Origin

Extracted from the Frost game project's install system.
