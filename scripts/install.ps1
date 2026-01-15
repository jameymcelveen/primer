#Requires -Version 5.1
<#
.SYNOPSIS
    Primer CLI Installer for Windows

.DESCRIPTION
    Installs the Primer CLI on Windows systems.

.EXAMPLE
    irm https://primer.dev/install.ps1 | iex

.EXAMPLE
    ./install.ps1 -Version 0.1.0
#>

param(
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

# Config
$NpmPackage = "@primer-bootstrap/cli"
$RepoUrl = "https://github.com/jameymcelveen/primer.git"
$InstallDir = if ($env:PRIMER_INSTALL_DIR) { $env:PRIMER_INSTALL_DIR } else { "$env:USERPROFILE\.primer" }

# Colors for output
function Write-Color {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

function Write-Info { 
    Write-Host "info " -ForegroundColor Blue -NoNewline
    Write-Host $args[0]
}

function Write-Success { 
    Write-Host "✓ " -ForegroundColor Green -NoNewline
    Write-Host $args[0]
}

function Write-Warn { 
    Write-Host "warn " -ForegroundColor Yellow -NoNewline
    Write-Host $args[0]
}

function Write-Err { 
    Write-Host "error " -ForegroundColor Red -NoNewline
    Write-Host $args[0]
    exit 1
}

function Write-Header {
    Write-Host ""
    Write-Host "══════════════════════════════════════════" -ForegroundColor White
    Write-Host "  🎨 Primer CLI Installer" -ForegroundColor White
    Write-Host "══════════════════════════════════════════" -ForegroundColor White
    Write-Host ""
}

# Check requirements
function Test-Requirements {
    # Check Node.js
    try {
        $nodeVersion = node -v 2>$null
        if (-not $nodeVersion) {
            throw "not found"
        }
        
        $major = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        if ($major -lt 18) {
            Write-Err "Node.js 18+ is required. Current version: $nodeVersion"
        }
        
        Write-Success "Node.js $nodeVersion detected"
    }
    catch {
        Write-Err "Node.js is required but not installed. Install it from https://nodejs.org"
    }
}

# Install via npm
function Install-ViaNpm {
    Write-Info "Installing via npm..."
    
    if ($Version -eq "latest") {
        npm install -g $NpmPackage
    }
    else {
        npm install -g "$NpmPackage@$Version"
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "npm install failed"
    }
    
    Write-Success "Installed primer via npm"
}

# Install via git
function Install-ViaGit {
    Write-Info "Installing via git..."
    
    # Check git
    try {
        git --version | Out-Null
    }
    catch {
        Write-Err "Git is required for this installation method"
    }
    
    # Clone or update
    if (Test-Path $InstallDir) {
        Write-Info "Updating existing installation..."
        Push-Location $InstallDir
        git pull origin main
    }
    else {
        Write-Info "Cloning primer..."
        git clone $RepoUrl $InstallDir
        Push-Location $InstallDir
    }
    
    # Install dependencies
    Write-Info "Installing dependencies..."
    npm install
    
    # Link globally
    Write-Info "Linking globally..."
    npm link
    
    Pop-Location
    
    Write-Success "Installed primer via git"
}

# Verify installation
function Test-Installation {
    try {
        $version = primer --version 2>$null
        Write-Success "primer $version installed successfully!"
        Write-Host ""
        Write-Host "  Get started:" -ForegroundColor Cyan
        Write-Host "    primer init        # Initialize a new project"
        Write-Host "    primer list        # List available modules"
        Write-Host "    primer --help      # Show help"
        Write-Host ""
    }
    catch {
        Write-Warn "primer installed but may need terminal restart"
        Write-Warn "Close and reopen PowerShell, then try: primer --version"
    }
}

# Main
function Main {
    Write-Header
    Test-Requirements
    
    # Check if npm is available
    try {
        npm --version | Out-Null
        
        # Check if package is published
        $packageInfo = npm view $NpmPackage version 2>$null
        if ($packageInfo) {
            Install-ViaNpm
        }
        else {
            Write-Info "npm package not yet published, using git installation..."
            Install-ViaGit
        }
    }
    catch {
        Install-ViaGit
    }
    
    Test-Installation
}

Main
