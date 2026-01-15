#!/bin/zsh
#
# Docker Module - Dockerfile, docker-compose.yml
#

: ${GREEN:='\033[0;32m'}
: ${YELLOW:='\033[1;33m'}
: ${DIM:='\033[2m'}
: ${NC:='\033[0m'}
: ${ICON_OK:="✓"}
: ${ICON_MISSING:="✗"}
: ${ICON_ARROW:="→"}

command_exists() {
    command -v "$1" &> /dev/null
}

# =============================================================================
# Checks
# =============================================================================

check_docker() {
    if command_exists docker; then
        echo -e "    ${GREEN}${ICON_OK}${NC} Docker installed"
        return 0
    else
        echo -e "    ${YELLOW}${ICON_MISSING}${NC} Docker not installed"
        return 1
    fi
}

# =============================================================================
# Installs
# =============================================================================

install_docker() {
    if ! command_exists docker; then
        echo -e "    ${ICON_ARROW} Installing Docker..."
        brew install --cask docker
        echo -e "    ${YELLOW}Note: Open Docker.app to complete setup${NC}"
    fi
}

create_dockerfile() {
    if [[ ! -f "Dockerfile" ]]; then
        echo -e "    ${ICON_ARROW} Creating Dockerfile..."
        cat > Dockerfile << 'EOF'
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF
    fi
}

create_docker_compose() {
    if [[ ! -f "docker-compose.yml" ]]; then
        echo -e "    ${ICON_ARROW} Creating docker-compose.yml..."
        cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
EOF
    fi
}

create_dockerignore() {
    if [[ ! -f ".dockerignore" ]]; then
        echo -e "    ${ICON_ARROW} Creating .dockerignore..."
        cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.env
.DS_Store
EOF
    fi
}

# =============================================================================
# Main
# =============================================================================

echo -e "    ${DIM}Checking Docker...${NC}"
check_docker

echo -e "    ${DIM}Setting up Docker...${NC}"
install_docker
create_dockerfile
create_docker_compose
create_dockerignore

echo -e "    ${GREEN}${ICON_OK}${NC} Docker module complete"
