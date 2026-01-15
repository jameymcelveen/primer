# 🎨 Primer

A composable, idempotent project bootstrapping system.

Think of it like Docker Compose for project setup — define what you need in a config file, and Primer installs & configures everything.

## Installation

```bash
# npm (recommended)
npm install -g @primer-bootstrap/cli

# or curl
curl -fsSL https://primer.dev/install.sh | bash

# or homebrew (coming soon)
brew tap jameymcelveen/primer
brew install primer
```

## Quick Start

```bash
# Create a new project
mkdir my-awesome-app && cd my-awesome-app

# Initialize with interactive wizard
primer init

# Or quick setup with defaults
primer init --yes
```

## Commands

| Command | Description |
|---------|-------------|
| `primer init` | Initialize a new project (interactive) |
| `primer init --yes` | Quick setup with defaults |
| `primer add <modules...>` | Add modules to your project |
| `primer list` | List available modules |
| `primer run` | Run modules from primer.yaml |
| `primer --help` | Show help |

## Available Modules

| Module | Description |
|--------|-------------|
| `base` | Git, Homebrew, GitHub CLI, Makefile, .gitignore |
| `godot-mono` | Godot 4 with .NET/C# support |
| `nodejs` | Node.js, npm, package.json |
| `python` | Python, venv, requirements.txt |
| `mobile` | iOS/Android export preparation |
| `git-hooks` | Pre-commit hooks, branch protection |
| `docker` | Dockerfile, docker-compose.yml |

## Config File

Primer creates a `primer.yaml` in your project:

```yaml
name: my-awesome-app
description: My project description

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

Re-run modules anytime:

```bash
primer run
```

## Key Features

- **🧩 Composable** — Mix and match modules for your stack
- **🔄 Idempotent** — Safe to run multiple times
- **📝 Declarative** — Define config in YAML
- **💬 Interactive** — Friendly wizard for project setup
- **🔌 Extensible** — Easy to add custom modules
- **🌍 Cross-Platform** — Works on macOS, Linux (Windows coming soon)

## Adding Custom Modules

Create a module in `modules/your-module/`:

```
modules/your-module/
├── install.sh        # Install script (required)
└── description.txt   # One-line description
```

The install script should be idempotent (check state → install if needed → verify).

## Development

```bash
# Clone and setup
git clone https://github.com/jameymcelveen/primer.git
cd primer
npm install
npm link

# Test locally
primer --version
primer list
```

## License

MIT
