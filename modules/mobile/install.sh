#!/bin/zsh
#
# Mobile Module - iOS/Android export preparation
#

: ${GREEN:='\033[0;32m'}
: ${YELLOW:='\033[1;33m'}
: ${DIM:='\033[2m'}
: ${NC:='\033[0m'}
: ${ICON_OK:="✓"}
: ${ICON_MISSING:="✗"}
: ${ICON_ARROW:="→"}

# =============================================================================
# Checks
# =============================================================================

check_xcode() {
    if xcode-select -p &> /dev/null; then
        echo -e "    ${GREEN}${ICON_OK}${NC} Xcode Command Line Tools installed"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Xcode Command Line Tools not installed"
        return 1
    fi
}

check_xcode_app() {
    if [[ -d "/Applications/Xcode.app" ]]; then
        echo -e "    ${GREEN}${ICON_OK}${NC} Xcode.app installed"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Xcode.app not installed (needed for iOS builds)"
        return 1
    fi
}

# =============================================================================
# Installs
# =============================================================================

install_xcode_cli() {
    if ! xcode-select -p &> /dev/null; then
        echo -e "    ${ICON_ARROW} Installing Xcode Command Line Tools..."
        xcode-select --install 2>/dev/null || true
        echo -e "    ${YELLOW}Note: Follow the popup to complete installation${NC}"
    fi
}

create_export_notes() {
    if [[ ! -f "MOBILE_EXPORT.md" ]]; then
        echo -e "    ${ICON_ARROW} Creating mobile export notes..."
        cat > MOBILE_EXPORT.md << 'EOF'
# Mobile Export Notes

## iOS Requirements
1. Apple Developer Account ($99/year)
2. Xcode installed from App Store
3. iOS export templates (download in Godot: Editor → Manage Export Templates)
4. Provisioning profile and signing certificate

## Android Requirements
1. Android SDK (install via Android Studio or command line)
2. Android export templates (download in Godot)
3. Keystore for signing release builds

## Godot Export Steps
1. Project → Export → Add → iOS/Android
2. Configure bundle ID and signing
3. Export to .ipa (iOS) or .apk (Android)

## Testing
- iOS: Use Xcode to deploy to connected device
- Android: Enable USB debugging, use adb install
EOF
    fi
}

# =============================================================================
# Main
# =============================================================================

echo -e "    ${DIM}Checking mobile requirements...${NC}"
check_xcode
check_xcode_app

echo -e "    ${DIM}Setting up mobile export...${NC}"
install_xcode_cli
create_export_notes

echo -e "    ${GREEN}${ICON_OK}${NC} Mobile module complete"
echo -e "    ${DIM}See MOBILE_EXPORT.md for detailed instructions${NC}"
